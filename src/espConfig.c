/*
    espConfig.c -- ESP Configuration

    Copyright (c) All Rights Reserved. See copyright notice at the bottom of the file.
 */

/*********************************** Includes *********************************/

#include    "esp.h"

/************************************* Locals *********************************/

#define ITERATE_CONFIG(route, obj, child, index) \
    index = 0, child = obj ? obj->children: 0; obj && index < obj->length && !route->error; child = child->next, index++

/************************************** Code **********************************/

static void parseApplications(HttpRoute *parent, cchar *key, MprJson *prop)
{
    HttpRoute   *route;
    MprJson     *child, *inc;
    MprList     *files;
    cchar       *path;
    int         ji, next;

    for (ITERATE_CONFIG(parent, inc, child, ji)) {
        files = mprGlobPathFiles(".", child->value, MPR_PATH_NO_DIRS | MPR_PATH_RELATIVE);
        for (ITERATE_ITEMS(files, path, next)) {
            parent = httpCreateInheritedRoute(route);
            route->flags |= HTTP_ROUTE_HOSTED;
#if UNUSED
            if (espDefineApp(route, name, prefix, home, documents, routeSet) < 0) {
                return MPR_ERR_CANT_CREATE;
            }
            if (prefix) {
                espSetConfig(route, "esp.appPrefix", prefix);
            }
#endif
            espConfigureApp(route);
            httpFinalizeRoute(route);
            espLoadApp(route);
        }
    }
    return 0;
}


static void parseCombine(HttpRoute *route, cchar *key, MprJson *prop)
{
    EspRoute    *eroute;

    eroute = route->eroute;
    if (smatch(prop->value, "true")) {
        eroute->combine = 1;
    } else {
        eroute->combine = 0;
    }
}


#if UNUSED
/*
    Define Visual Studio environment if not already present
 */
static void defineVisualStudioEnv(HttpRoute *route)
{
    Http    *http;
    int     is64BitSystem;

    http = MPR->httpService;
    if (scontains(getenv("LIB"), "Visual Studio") &&
        scontains(getenv("INCLUDE"), "Visual Studio") &&
        scontains(getenv("PATH"), "Visual Studio")) {
        return;
    }
    if (scontains(http->platform, "-x64-")) {
        is64BitSystem = smatch(getenv("PROCESSOR_ARCHITECTURE"), "AMD64") || getenv("PROCESSOR_ARCHITEW6432");
        defineEnv(route, "LIB", "${WINSDK}\\LIB\\${WINVER}\\um\\x64;${WINSDK}\\LIB\\x64;${VS}\\VC\\lib\\amd64");
        if (is64BitSystem) {
            defineEnv(route, "PATH",
                "${VS}\\Common7\\IDE;${VS}\\VC\\bin\\amd64;${VS}\\Common7\\Tools;${VS}\\SDK\\v3.5\\bin;"
                "${VS}\\VC\\VCPackages;${WINSDK}\\bin\\x64");

        } else {
            /* Cross building on x86 for 64-bit */
            defineEnv(route, "PATH",
                "${VS}\\Common7\\IDE;${VS}\\VC\\bin\\x86_amd64;"
                "${VS}\\Common7\\Tools;${VS}\\SDK\\v3.5\\bin;${VS}\\VC\\VCPackages;${WINSDK}\\bin\\x86");
        }

    } else if (scontains(http->platform, "-arm-")) {
        /* Cross building on x86 for arm. No winsdk 7 support for arm */
        defineEnv(route, "LIB", "${WINSDK}\\LIB\\${WINVER}\\um\\arm;${VS}\\VC\\lib\\arm");
        defineEnv(route, "PATH", "${VS}\\Common7\\IDE;${VS}\\VC\\bin\\x86_arm;${VS}\\Common7\\Tools;"
            "${VS}\\SDK\\v3.5\\bin;${VS}\\VC\\VCPackages;${WINSDK}\\bin\\arm");

    } else {
        /* Building for X86 */
        defineEnv(route, "LIB", "${WINSDK}\\LIB\\${WINVER}\\um\\x86;${WINSDK}\\LIB\\x86;"
            "${WINSDK}\\LIB;${VS}\\VC\\lib");
        defineEnv(route, "PATH", "${VS}\\Common7\\IDE;${VS}\\VC\\bin;${VS}\\Common7\\Tools;"
            "${VS}\\SDK\\v3.5\\bin;${VS}\\VC\\VCPackages;${WINSDK}\\bin");
    }
    defineEnv(route, "INCLUDE", "${VS}\\VC\\INCLUDE;${WINSDK}\\include;${WINSDK}\\include\\um;"
        "${WINSDK}\\include\\shared");
}
#endif


static void defineEnv(HttpRoute *route, cchar *key, cchar *value)
{
    EspRoute    *eroute;
    MprJson     *child, *set;
    cchar       *arch;
    int         ji;

    eroute = route->eroute;
    if (smatch(key, "set")) {
        httpParsePlatform(HTTP->platform, NULL, &arch, NULL);
#if ME_WIN_LIKE
        if (smatch(value, "VisualStudio")) {
            if (scontains(getenv("LIB"), "Visual Studio") &&
                scontains(getenv("INCLUDE"), "Visual Studio") &&
                scontains(getenv("PATH"), "Visual Studio")) {
                return;
            }
        }
        if (scontains(HTTP->platform, "-x64-") &&
            !(smatch(getenv("PROCESSOR_ARCHITECTURE"), "AMD64") || getenv("PROCESSOR_ARCHITEW6432"))) {
            /* Cross 64 */
            arch = sjoin(arch, "-cross", NULL);
        }
#endif
        if ((set = mprGetJsonObj(route->config, sfmt("esp.build.env.%s.default", value))) != 0) {
            for (ITERATE_CONFIG(route, set, child, ji)) {
                defineEnv(route, child->name, child->value);
            }
        }
        if ((set = mprGetJsonObj(route->config, sfmt("esp.build.env.%s.%s", value, arch))) == 0) {
            httpParseError(route, "Cannnot find environment set %s.%s", value, arch);
            return;
        } else {
            for (ITERATE_CONFIG(route, set, child, ji)) {
                defineEnv(route, child->name, child->value);
            }
        }

    } else {
        value = espExpandCommand(route, value, "", "");
        mprAddKey(eroute->env, key, value);
        if (scaselessmatch(key, "PATH")) {
            if (eroute->searchPath) {
                eroute->searchPath = sclone(value);
            } else {
                eroute->searchPath = sjoin(eroute->searchPath, MPR_SEARCH_SEP, value, NULL);
            }
        }
    }
}


static void parseBuild(HttpRoute *route, cchar *key, MprJson *prop)
{
    EspRoute    *eroute;
    MprJson     *child, *env, *rules;
    cchar       *buildType, *os, *rule, *stem;
    int         ji;

    eroute = route->eroute;
    buildType = HTTP->staticLink ? "static" : "dynamic";
    httpParsePlatform(HTTP->platform, &os, NULL, NULL);

    stem = sfmt("esp.build.rules.%s.%s", buildType, os);
    if ((rules = mprGetJsonObj(route->config, stem)) != 0) {
        if ((rule = mprGetJson(route->config, sfmt("%s.%s", stem, "compile"))) != 0) {
            eroute->compile = rule;
        }
        if ((rule = mprGetJson(route->config, sfmt("%s.%s", stem, "link"))) != 0) {
            eroute->link = rule;
        }
        if ((env = mprGetJsonObj(route->config, sfmt("%s.%s", stem, "env"))) != 0) {
            if (eroute->env == 0) {
                eroute->env = mprCreateHash(-1, MPR_HASH_STABLE);
            }
            for (ITERATE_CONFIG(route, env, child, ji)) {
                defineEnv(route, child->name, child->value);
            }
        }
    }
}


static void parseOptimize(HttpRoute *route, cchar *key, MprJson *prop)
{
    EspRoute    *eroute;

    eroute = route->eroute;
    eroute->compileMode = smatch(prop->value, "true") ? ESP_COMPILE_OPTIMIZED : ESP_COMPILE_SYMBOLS;
}

static void serverRouteSet(HttpRoute *route, cchar *set)
{
    httpAddRestfulRoute(route, "GET,POST", "/{action}(/)*$", "${action}", "{controller}");
}


static void restfulRouteSet(HttpRoute *route, cchar *set)
{
    httpAddResourceGroup(route, "{controller}");
}

static void legacyRouteSet(HttpRoute *route, cchar *set)
{
    restfulRouteSet(route, "restful");
}


PUBLIC int espInitParser() 
{
    httpDefineRouteSet("esp-server", serverRouteSet);
    httpDefineRouteSet("esp-restful", restfulRouteSet);
#if DEPRECATED || 1
    httpDefineRouteSet("esp-angular-mvc", legacyRouteSet);
    httpDefineRouteSet("esp-html-mvc", legacyRouteSet);
#endif
    
    httpAddConfig("esp", httpParseAll);
    httpAddConfig("esp.build", parseBuild);
    httpAddConfig("esp.combine", parseCombine);
    httpAddConfig("esp.optimize", parseOptimize);
    return 0;
} 

/*
    @copy   default

    Copyright (c) Embedthis Software LLC, 2003-2014. All Rights Reserved.

    This software is distributed under commercial and open source licenses.
    You may use the Embedthis Open Source license or you may acquire a 
    commercial license from Embedthis Software. You agree to be fully bound
    by the terms of either license. Consult the LICENSE.md distributed with
    this software for full details and other copyrights.

    Local variables:
    tab-width: 4
    c-basic-offset: 4
    End:
    vim: sw=4 ts=4 expandtab

    @end
 */
