/*
    espConfig.c -- ESP Configuration

    Copyright (c) All Rights Reserved. See copyright notice at the bottom of the file.
 */

/*********************************** Includes *********************************/

#include    "esp.h"

/************************************** Code **********************************/


static void parseEsp(HttpRoute *route, cchar *key, MprJson *prop)
{
    httpParseAll(route, key, prop);
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

static void parseCompile(HttpRoute *route, cchar *key, MprJson *prop)
{
    EspRoute    *eroute;

    eroute = route->eroute;
    if (smatch(prop->value, "debug") || smatch(prop->value, "symbols")) {
        eroute->compileMode = ESP_COMPILE_SYMBOLS;
    } else if (smatch(prop->value, "release") || smatch(prop->value, "optimized")) {
        eroute->compileMode = ESP_COMPILE_OPTIMIZED;
    }
}

static void serverRouteSet(HttpRoute *parent, cchar *set)
{
    HttpRoute   *route;

    /* Simple controller/action route */
    httpSetRouteXsrf(parent, 1);
    route = httpAddRestfulRoute(parent, parent->serverPrefix, "action", "GET,POST","/{action}(/)*$",
        "${action}", "{controller}");
    httpAddPublicRoute(parent, "", "/public");
    httpAddRouteHandler(route, "espHandler", "");
}


static void angularRouteSet(HttpRoute *parent, cchar *set)
{
    httpSetRouteXsrf(parent, 1);
    httpAddRouteHandler(parent, "espHandler", "");
    httpAddWebSocketsRoute(parent, 0, "/*/stream");
    httpAddResourceGroup(parent, 0, "{controller}");
    httpAddPublicRoute(parent, "", "/public");
    httpHideRoute(parent, 1);
}


static void htmlRouteSet(HttpRoute *parent, cchar *set)
{
    httpSetRouteXsrf(parent, 1);
    httpAddRouteHandler(parent, "espHandler", "");
    httpDefineRoute(parent,
        sfmt("%s%s/*", parent->prefix, parent->serverPrefix), 
        "GET", 
        sfmt("^%s%s/{controller}$", parent->prefix, parent->serverPrefix),
        "$1", 
        "${controller}.c");
    httpAddResourceGroup(parent, 0, "{controller}");
    httpAddPublicRoute(parent, "", "/public");
    httpHideRoute(parent, 1);
}


PUBLIC int espInitParser() 
{
    httpDefineRouteSet("esp-server", serverRouteSet);
    httpDefineRouteSet("esp-angular-mvc", angularRouteSet);
    httpDefineRouteSet("esp-html-mvc", htmlRouteSet);

    httpAddConfig("esp", parseEsp);
    httpAddConfig("esp.combine", parseCombine);
    httpAddConfig("esp.compile", parseCompile);
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
