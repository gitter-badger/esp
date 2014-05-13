/*
    espConfig.c -- ESP Configuration

    Copyright (c) All Rights Reserved. See copyright notice at the bottom of the file.
 */

/*********************************** Includes *********************************/

#include    "esp.h"

/************************************** Code **********************************/

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


static void serverRouteSet(HttpRoute *route, cchar *set)
{
    /* Simple controller/action route */
    httpAddRestfulRoute(route, route->serverPrefix, "action", "GET,POST","/{action}(/)*$", 
        "${action}", "{controller}");
    httpAddClientRoute(route, "", "/public");
    httpHideRoute(route, 1);
}


static void angularRouteSet(HttpRoute *route, cchar *set)
{
    httpAddWebSocketsRoute(route, route->serverPrefix, "/*/stream");
    httpAddResourceGroup(route, route->serverPrefix, "{controller}");
    httpAddClientRoute(route, "", "/public");
    httpHideRoute(route, 1);
}


static void htmlRouteSet(HttpRoute *route, cchar *set)
{
    httpDefineRoute(route, sfmt("%s/*", route->serverPrefix), "GET", sfmt("^%s/{controller}$", route->serverPrefix), "$1", "${controller}.c");
    httpAddRestfulRoute(route, route->serverPrefix, "delete", "POST", "/{id=[0-9]+}/delete$", "delete", "{controller}");
    httpAddResourceGroup(route, route->serverPrefix, "{controller}");
    httpAddClientRoute(route, "", "/public");
    httpHideRoute(route, 1);
}


PUBLIC int espInitParser() 
{
    httpDefineRouteSet("esp-server", serverRouteSet);
    httpDefineRouteSet("esp-angular-mvc", angularRouteSet);
    httpDefineRouteSet("esp-html-mvc", htmlRouteSet);
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
