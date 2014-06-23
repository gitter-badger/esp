/*
    espHandler.c -- ESP Appweb handler

    Copyright (c) All Rights Reserved. See copyright notice at the bottom of the file.
 */

/********************************** Includes **********************************/

#include    "esp.h"

/************************************* Local **********************************/
/*
    Singleton ESP control structure
 */
static Esp *esp;

/************************************ Forward *********************************/

static int cloneDatabase(HttpConn *conn);
static void closeEsp(HttpQueue *q);
static EspRoute *initRoute(HttpRoute *route);
static int espDbDirective(MaState *state, cchar *key, cchar *value);
static int espEnvDirective(MaState *state, cchar *key, cchar *value);
static EspRoute *getEroute(HttpRoute *route);
static void manageEsp(Esp *esp, int flags);
static void manageReq(EspReq *req, int flags);
static int runAction(HttpConn *conn);
static int unloadEsp(MprModule *mp);
static bool pageExists(HttpConn *conn);

#if !ME_STATIC
static char *getModuleEntry(EspRoute *eroute, cchar *kind, cchar *source, cchar *cacheName);
static bool layoutIsStale(EspRoute *eroute, cchar *source, cchar *module);
static bool loadApp(HttpRoute *route, MprDispatcher *dispatcher);
#endif

/************************************* Code ***********************************/
/*
    Open an instance of the ESP for a new request
 */
static int openEsp(HttpQueue *q)
{
    HttpConn    *conn;
    HttpRx      *rx;
    HttpRoute   *route;
    EspRoute    *eroute;
    EspReq      *req;

    conn = q->conn;
    rx = conn->rx;

    if ((req = mprAllocObj(EspReq, manageReq)) == 0) {
        httpMemoryError(conn);
        return MPR_ERR_MEMORY;
    }

    /*
        If unloading a module, this lock will cause a wait here while ESP applications are reloaded.
        Do not use atomic APIs here
     */
    lock(esp);
    esp->inUse++;
    unlock(esp);

    /*
        Find the ESP route configuration. Search up the route parent chain.
     */
    for (eroute = 0, route = rx->route; route; route = route->parent) {
        if (route->eroute) {
            eroute = route->eroute;
            break;
        }
    }
    if (!route) {
        route = rx->route;
        eroute = initRoute(route);
    }
    if (!eroute) {
        httpError(conn, 0, "Cannot find a suitable ESP route");
        closeEsp(q);
        return MPR_ERR_CANT_OPEN;
    }
    conn->reqData = req;
    req->esp = esp;
    req->route = route;
    req->autoFinalize = 1;
    /*
        If a cookie is not explicitly set, use the application name for the session cookie
     */
    if (!route->cookie && eroute->appName && *eroute->appName) {
        route->cookie = eroute->appName;
    }
    return 0;
}


static void closeEsp(HttpQueue *q)
{
    lock(esp);
    esp->inUse--;
    assert(esp->inUse >= 0);
    unlock(esp);
}


#if !ME_STATIC
/*
    This is called when unloading a view or controller module
    All of ESP must be quiesced.
 */
static bool espUnloadModule(cchar *module, MprTicks timeout)
{
    MprModule   *mp;
    MprTicks    mark;

    if ((mp = mprLookupModule(module)) != 0) {
        mark = mprGetTicks();
        esp->reloading = 1;
        do {
            lock(esp);
            /* Own request will count as 1 */
            if (esp->inUse <= 1) {
                if (mprUnloadModule(mp) < 0) {
                    mprLog("error esp", 0, "Cannot unload module %s", mp->name);
                    unlock(esp);
                }
                esp->reloading = 0;
                unlock(esp);
                return 1;
            }
            unlock(esp);
            mprSleep(10);

        } while (mprGetRemainingTicks(mark, timeout) > 0);
        esp->reloading = 0;
    }
    return 0;
}
#endif


PUBLIC void espClearFlash(HttpConn *conn)
{
    EspReq      *req;

    req = conn->reqData;
    req->flash = 0;
}


static void setupFlash(HttpConn *conn)
{
    EspReq      *req;

    req = conn->reqData;
    if (httpGetSession(conn, 0)) {
        req->flash = httpGetSessionObj(conn, ESP_FLASH_VAR);
        req->lastFlash = 0;
        if (req->flash) {
            httpRemoveSessionVar(conn, ESP_FLASH_VAR);
            req->lastFlash = mprCloneHash(req->flash);
        }
    }
}


static void pruneFlash(HttpConn *conn)
{
    EspReq  *req;
    MprKey  *kp, *lp;

    req = conn->reqData;
    if (req->flash && req->lastFlash) {
        for (ITERATE_KEYS(req->flash, kp)) {
            for (ITERATE_KEYS(req->lastFlash, lp)) {
                if (smatch(kp->key, lp->key)) {
                    mprRemoveKey(req->flash, kp->key);
                }
            }
        }
    }
}


static void finalizeFlash(HttpConn *conn)
{
    EspReq  *req;

    req = conn->reqData;
    if (req->flash && mprGetHashLength(req->flash) > 0) {
        /*
            If the session does not exist, this will create one. However, must not have
            emitted the headers, otherwise cannot inform the client of the session cookie.
        */
        httpSetSessionObj(conn, ESP_FLASH_VAR, req->flash);
    }
}


/*
    Start the request. At this stage, body data may not have been fully received unless
    the request is a form (POST method and Content-Type is application/x-www-form-urlencoded).
    Forms are a special case and delay invoking the start callback until all body data is received.
    WARNING: GC yield
 */
static void startEsp(HttpQueue *q)
{
    HttpConn    *conn;
    HttpRoute   *route;
    EspRoute    *eroute;
    EspReq      *req;
    cchar       *view;

    conn = q->conn;
    route = conn->rx->route;
    eroute = route->eroute;
    req = conn->reqData;

    if (req) {
        mprSetThreadData(req->esp->local, conn);
        httpAuthenticate(conn);
        setupFlash(conn);
        /*
            See if the esp configuration or app needs to be reloaded.
         */
        if (eroute->appName && httpLoadConfig(route, ME_ESP_PACKAGE) < 0) {
            httpError(conn, HTTP_CODE_NOT_FOUND, "Cannot load esp config for %s", eroute->appName);
            return;
        }
#if !ME_STATIC
        /* WARNING: GC yield */
        if (!loadApp(route, conn->dispatcher)) {
            httpError(conn, HTTP_CODE_NOT_FOUND, "Cannot load esp module for %s", eroute->appName);
            return;
        }
#endif
        /* WARNING: GC yield */
        if (!runAction(conn)) {
            pruneFlash(conn);
        } else {
            if (req->autoFinalize) {
                if (!conn->tx->responded) {
                    view = (route->sourceName && route->sourceName) ? conn->rx->target : NULL;
                    /* WARNING: GC yield */
                    espRenderView(conn, view);
                }
                if (req->autoFinalize) {
                    espFinalize(conn);
                }
            }
            pruneFlash(conn);
        }
        finalizeFlash(conn);
        mprSetThreadData(req->esp->local, NULL);
    }
}


static int runAction(HttpConn *conn)
{
    HttpRx      *rx;
    HttpRoute   *route;
    EspRoute    *eroute;
    EspReq      *req;
    EspAction   action;
    cchar       *controllersDir;
    char        *actionName, *key, *filename, *source;

    rx = conn->rx;
    req = conn->reqData;
    route = rx->route;
    eroute = route->eroute;
    assert(eroute);

    if (eroute->edi && eroute->edi->flags & EDI_PRIVATE) {
        cloneDatabase(conn);
    } else {
        req->edi = eroute->edi;
    }
    if (route->sourceName == 0 || *route->sourceName == '\0') {
        if (eroute->commonController) {
            (eroute->commonController)(conn);
        }
        return 1;
    }
    /*
        Expand any form var $tokens. This permits ${controller} and user form data to be used in the controller name
     */
    filename = schr(route->sourceName, '$') ? stemplateJson(route->sourceName, rx->params) : route->sourceName;
    controllersDir = httpGetDir(route, "controllers");
    source = controllersDir ? mprJoinPath(controllersDir, filename) : mprJoinPath(route->home, filename);

#if !ME_STATIC
    key = mprJoinPath(controllersDir, rx->target);
    if (!route->combine && (route->update || !mprLookupKey(esp->actions, key))) {
        cchar *errMsg;
        if (espLoadModule(route, conn->dispatcher, "controller", source, &errMsg) < 0) {
            httpError(conn, HTTP_CODE_NOT_FOUND, "%s", errMsg);
            return 0;
        }
    }
#endif /* !ME_STATIC */
    key = mprJoinPath(controllersDir, rx->target);
    if ((action = mprLookupKey(esp->actions, key)) == 0) {
        if (!pageExists(conn)) {
            /*
                Actions are registered as: source/TARGET where TARGET is typically CONTROLLER-ACTION
             */
            key = sfmt("%s/missing", mprGetPathDir(source));
            if ((action = mprLookupKey(esp->actions, key)) == 0) {
                if ((action = mprLookupKey(esp->actions, "missing")) == 0) {
                    httpError(conn, HTTP_CODE_NOT_FOUND, "Missing action for \"%s\"", rx->target);
                    return 0;
                }
            }
        }
    }
    if (route->flags & HTTP_ROUTE_XSRF && !(rx->flags & HTTP_GET)) {
        if (!httpCheckSecurityToken(conn)) {
            httpSetStatus(conn, HTTP_CODE_UNAUTHORIZED);
            if (smatch(route->responseFormat, "json")) {
                httpTrace(conn, "esp.xsrf.error", "error", 0);
                espRenderString(conn,
                    "{\"retry\": true, \"success\": 0, \"feedback\": {\"error\": \"Security token is stale. Please retry.\"}}");
                espFinalize(conn);
            } else {
                httpError(conn, HTTP_CODE_UNAUTHORIZED, "Security token is stale. Please reload page.");
            }
            return 0;
        }
    }
    if (action) {
        httpSetParam(conn, "controller", stok(sclone(rx->target), "-", &actionName));
        httpSetParam(conn, "action", actionName);
        if (eroute->commonController) {
            (eroute->commonController)(conn);
        }
        if (!httpIsFinalized(conn)) {
            (action)(conn);
        }
    }
    return 1;
}


PUBLIC void espRenderView(HttpConn *conn, cchar *name)
{
    HttpRx      *rx;
    HttpRoute   *route;
    EspViewProc viewProc;
    cchar       *source;

    rx = conn->rx;
    route = rx->route;

    if (name) {
        source = mprJoinPathExt(mprJoinPath(httpGetDir(route, "views"), name), ".esp");
    } else {
        httpMapFile(conn);
        source = conn->tx->filename;
    }
#if !ME_STATIC
    if (!route->combine && (route->update || !mprLookupKey(esp->views, mprGetPortablePath(source)))) {
        cchar *errMsg;
        /* WARNING: GC yield */
        mprHold(source);
        if (espLoadModule(route, conn->dispatcher, "view", source, &errMsg) < 0) {
            mprRelease(source);
            httpError(conn, HTTP_CODE_NOT_FOUND, "%s", errMsg);
            return;
        }
        mprRelease(source);
    }
#endif
    if ((viewProc = mprLookupKey(esp->views, mprGetPortablePath(source))) == 0) {
        httpError(conn, HTTP_CODE_NOT_FOUND, "Cannot find view");
        return;
    }
    httpAddHeaderString(conn, "Content-Type", "text/html");
    if (rx->route->flags & HTTP_ROUTE_XSRF) {
        /* Add a new unique security token */
        httpAddSecurityToken(conn, 1);
    }
    /* WARNING: GC yield */
    (viewProc)(conn);
}


/************************************ Support *********************************/
/*
    Create a per user session database clone. Used for demos so one users updates to not change anothers view of the database
 */
static void pruneDatabases(Esp *esp)
{
    MprKey      *kp;

    lock(esp);
    for (ITERATE_KEYS(esp->databases, kp)) {
        if (!httpLookupSessionID(kp->key)) {
            mprRemoveKey(esp->databases, kp->key);
            /* Restart scan */
            kp = 0;
        }
    }
    unlock(esp);
}

static int cloneDatabase(HttpConn *conn)
{
    Esp         *esp;
    EspRoute    *eroute;
    EspReq      *req;
    cchar       *id;

    req = conn->reqData;
    eroute = conn->rx->route->eroute;
    assert(eroute->edi);
    assert(eroute->edi->flags & EDI_PRIVATE);

    esp = req->esp;
    if (!esp->databases) {
        lock(esp);
        if (!esp->databases) {
            esp->databases = mprCreateHash(0, 0);
            esp->databasesTimer = mprCreateTimerEvent(NULL, "esp-databases", 60 * 1000, pruneDatabases, esp, 0);
        }
        unlock(esp);
    }
    httpGetSession(conn, 1);
    id = httpGetSessionID(conn);
    if ((req->edi = mprLookupKey(esp->databases, id)) == 0) {
        if ((req->edi = ediClone(eroute->edi)) == 0) {
            mprLog("error esp", 0, "Cannot clone database: %s", eroute->edi->path);
            return MPR_ERR_CANT_OPEN;
        }
        mprAddKey(esp->databases, id, req->edi);
    }
    return 0;
}


#if !ME_STATIC
static char *getModuleEntry(EspRoute *eroute, cchar *kind, cchar *source, cchar *cacheName)
{
    char    *cp, *entry;

    if (smatch(kind, "view")) {
        entry = sfmt("esp_%s", cacheName);

    } else if (smatch(kind, "app")) {
        if (eroute->route->combine) {
            entry = sfmt("esp_%s_%s_combine", kind, eroute->appName);
        } else {
            entry = sfmt("esp_%s_%s", kind, eroute->appName);
        }
    } else {
        /* Controller */
        if (eroute->appName) {
            entry = sfmt("esp_%s_%s_%s", kind, eroute->appName, mprTrimPathExt(mprGetPathBase(source)));
        } else {
            entry = sfmt("esp_%s_%s", kind, mprTrimPathExt(mprGetPathBase(source)));
        }
    }
    for (cp = entry; *cp; cp++) {
        if (!isalnum((uchar) *cp) && *cp != '_') {
            *cp = '_';
        }
    }
    return entry;
}


/*
    WARNING: GC yield
 */
PUBLIC int espLoadModule(HttpRoute *route, MprDispatcher *dispatcher, cchar *kind, cchar *source, cchar **errMsg)
{
    EspRoute    *eroute;
    MprModule   *mp;
    cchar       *appName, *cacheName, *canonical, *entry, *module;
    int         isView, recompile;

    eroute = route->eroute;
    *errMsg = "";

#if VXWORKS
    /*
        Trim the drive for VxWorks where simulated host drives only exist on the target
     */
    source = mprTrimPathDrive(source);
#endif
    canonical = mprGetPortablePath(mprGetRelPath(source, route->documents));
    appName = eroute->appName ? eroute->appName : route->host->name;
    if (route->combine) {
        cacheName = eroute->appName;
    } else {
        cacheName = mprGetMD5WithPrefix(sfmt("%s:%s", appName, canonical), -1, sjoin(kind, "_", NULL));
    }
    module = mprNormalizePath(sfmt("%s/%s%s", httpGetDir(route, "cache"), cacheName, ME_SHOBJ));
    isView = smatch(kind, "view");

    lock(esp);
    if (route->update) {
        if (!mprPathExists(source, R_OK)) {
            *errMsg = sfmt("Cannot find %s \"%s\" to load", kind, source);
            unlock(esp);
            return MPR_ERR_CANT_FIND;
        }
        if (espModuleIsStale(source, module, &recompile) || (isView && layoutIsStale(eroute, source, module))) {
            if (recompile) {
                mprHoldBlocks(source, module, cacheName, NULL);
                if (!espCompile(route, dispatcher, source, module, cacheName, isView, (char**) errMsg)) {
                    mprReleaseBlocks(source, module, cacheName, NULL);
                    unlock(esp);
                    return MPR_ERR_CANT_WRITE;
                }
                mprReleaseBlocks(source, module, cacheName, NULL);
            }
        }
    }
    if (mprLookupModule(source) == 0) {
        entry = getModuleEntry(eroute, kind, source, cacheName);
        if ((mp = mprCreateModule(source, module, entry, route)) == 0) {
            *errMsg = "Memory allocation error loading module";
            unlock(esp);
            return MPR_ERR_MEMORY;
        }
        if (mprLoadModule(mp) < 0) {
            *errMsg = "Cannot load compiled esp module";
            unlock(esp);
            return MPR_ERR_CANT_READ;
        }
    }
    unlock(esp);
    return 0;
}


/*
    WARNING: GC yield
 */
static bool loadApp(HttpRoute *route, MprDispatcher *dispatcher)
{
    EspRoute    *eroute;
    cchar       *source, *errMsg;

    eroute = route->eroute;
    if (!eroute->appName) {
        return 1;
    }
    if (route->loaded && !route->update) {
        return 1;
    }
    if (route->combine) {
        source = mprJoinPath(httpGetDir(route, "cache"), sfmt("%s.c", eroute->appName));
    } else {
        source = mprJoinPath(httpGetDir(route, "src"), "app.c");
    }
    if (mprPathExists(source, R_OK)) {
        if (espLoadModule(route, dispatcher, "app", source, &errMsg) < 0) {
            mprLog("error esp", 0, "%s", errMsg);
            return 0;
        }
    }
    route->loaded = 1;
    return 1;
}


/*
    Test if a module has been updated (is stale).
    This will unload the module if it loaded but stale.
    Set recompile to true if the source is absent or more recent.
    Will return false if the source does not exist (important for testing layouts).
 */
PUBLIC bool espModuleIsStale(cchar *source, cchar *module, int *recompile)
{
    MprModule   *mp;
    MprPath     sinfo, minfo;

    *recompile = 0;
    mprGetPathInfo(module, &minfo);
    if (!minfo.valid) {
        if ((mp = mprLookupModule(source)) != 0) {
            if (!espUnloadModule(source, ME_ESP_RELOAD_TIMEOUT)) {
                mprLog("error esp", 0, "Cannot unload module %s. Connections still open. Continue using old version.", source);
                return 0;
            }
        }
        *recompile = 1;
        mprLog("info esp", 4, "Source %s is newer than module %s, recompiling ...", source, module);
        return 1;
    }
    mprGetPathInfo(source, &sinfo);
    if (sinfo.valid && sinfo.mtime > minfo.mtime) {
        if ((mp = mprLookupModule(source)) != 0) {
            if (!espUnloadModule(source, ME_ESP_RELOAD_TIMEOUT)) {
                mprLog("warn esp", 4, "Cannot unload module %s. Connections still open. Continue using old version.", source);
                return 0;
            }
        }
        *recompile = 1;
        mprLog("info esp", 4, "Source %s is newer than module %s, recompiling ...", source, module);
        return 1;
    }
    if ((mp = mprLookupModule(source)) != 0) {
        if (minfo.mtime > mp->modified) {
            /* Module file has been updated */
            if (!espUnloadModule(source, ME_ESP_RELOAD_TIMEOUT)) {
                mprLog("warn esp", 4, "Cannot unload module %s. Connections still open. Continue using old version.", source);
                return 0;
            }
            mprLog("info esp", 4, "Module %s has been externally updated, reloading ...", module);
            return 1;
        }
    }
    /* Loaded module is current */
    return 0;
}


/*
    Check if the layout has changed. Returns false if the layout does not exist.
 */
static bool layoutIsStale(EspRoute *eroute, cchar *source, cchar *module)
{
    char    *data, *lpath, *quote;
    cchar   *layout, *layoutsDir;
    ssize   len;
    bool    stale;
    int     recompile;

    stale = 0;
    layoutsDir = httpGetDir(eroute->route, "layouts");
    if ((data = mprReadPathContents(source, &len)) != 0) {
        if ((lpath = scontains(data, "@ layout \"")) != 0) {
            lpath = strim(&lpath[10], " ", MPR_TRIM_BOTH);
            if ((quote = schr(lpath, '"')) != 0) {
                *quote = '\0';
            }
            layout = (layoutsDir && *lpath) ? mprJoinPath(layoutsDir, lpath) : 0;
        } else {
            layout = (layoutsDir) ? mprJoinPath(layoutsDir, "default.esp") : 0;
        }
        if (layout) {
            stale = espModuleIsStale(layout, module, &recompile);
            if (stale) {
                mprLog("info esp", 4, "esp layout %s is newer than module %s", layout, module);
            }
        }
    }
    return stale;
}
#else

PUBLIC bool espModuleIsStale(cchar *source, cchar *module, int *recompile)
{
    return 0;
}
#endif /* ME_STATIC */


/*
    Test if the the required ESP page exists
 */
static bool pageExists(HttpConn *conn)
{
    HttpRx      *rx;
    cchar       *source, *dir;

    rx = conn->rx;
    if ((dir = httpGetDir(rx->route, "views")) == 0) {
        dir = rx->route->documents;
    }
    source = mprJoinPathExt(mprJoinPath(dir, rx->target), ".esp");
    return mprPathExists(source, R_OK);
}


/************************************ Esp Route *******************************/
/*
    Public so that esp.c can also call
 */
PUBLIC void espManageEspRoute(EspRoute *eroute, int flags)
{
    if (flags & MPR_MANAGE_MARK) {
        mprMark(eroute->appName);
        mprMark(eroute->compile);
        mprMark(eroute->combineScript);
        mprMark(eroute->combineSheet);
        mprMark(eroute->currentSession);
        mprMark(eroute->edi);
        mprMark(eroute->env);
        mprMark(eroute->link);
        mprMark(eroute->searchPath);
        mprMark(eroute->winsdk);
    }
}


PUBLIC EspRoute *espCreateRoute(HttpRoute *route)
{
    EspRoute    *eroute;

    if ((eroute = mprAllocObj(EspRoute, espManageEspRoute)) == 0) {
        return 0;
    }
    eroute->route = route;
    route->eroute = eroute;
#if ME_DEBUG
    eroute->compileMode = ESP_COMPILE_SYMBOLS;
#else
    eroute->compileMode = ESP_COMPILE_OPTIMIZED;
#endif
    return eroute;
}


static EspRoute *initRoute(HttpRoute *route)
{
    EspRoute    *eroute;

    if (route->eroute) {
        eroute = route->eroute;
        return eroute;
    }
    return espCreateRoute(route);
}


static EspRoute *cloneEspRoute(HttpRoute *route, EspRoute *parent)
{
    EspRoute      *eroute;

    assert(parent);
    assert(route);

    if ((eroute = mprAllocObj(EspRoute, espManageEspRoute)) == 0) {
        return 0;
    }
    eroute->route = route;
    eroute->top = parent->top;
    eroute->searchPath = parent->searchPath;
    eroute->edi = parent->edi;
    eroute->commonController = parent->commonController;
    if (parent->compile) {
        eroute->compile = sclone(parent->compile);
    }
    if (parent->link) {
        eroute->link = sclone(parent->link);
    }
    if (parent->env) {
        eroute->env = mprCloneHash(parent->env);
    }
    eroute->appName = parent->appName;
    eroute->combineScript = parent->combineScript;
    eroute->combineSheet = parent->combineSheet;
    route->eroute = eroute;
    return eroute;
}


/*
    Manage all links for EspReq for the garbage collector
 */
static void manageReq(EspReq *req, int flags)
{
    if (flags & MPR_MANAGE_MARK) {
        mprMark(req->commandLine);
        mprMark(req->flash);
        mprMark(req->feedback);
        mprMark(req->route);
        mprMark(req->data);
        mprMark(req->edi);
    }
}


/*
    Manage all links for Esp for the garbage collector
 */
static void manageEsp(Esp *esp, int flags)
{
    if (flags & MPR_MANAGE_MARK) {
        mprMark(esp->actions);
        mprMark(esp->databases);
        mprMark(esp->databasesTimer);
        mprMark(esp->ediService);
        mprMark(esp->local);
        mprMark(esp->mutex);
        mprMark(esp->views);
    }
}


/*
    Get a dedicated EspRoute for an HttpRoute. Allocate if required.
    It is expected that the caller will modify the EspRoute.
 */
static EspRoute *getEroute(HttpRoute *route)
{
    HttpRoute   *rp;

    if (route->eroute) {
        if (!route->parent || route->parent->eroute != route->eroute) {
            return route->eroute;
        }
    }
    /*
        Lookup up the route chain for any configured EspRoutes
     */
    for (rp = route; rp; rp = rp->parent) {
        if (rp->eroute) {
            return cloneEspRoute(route, rp->eroute);
        }
    }
    return initRoute(route);
}


PUBLIC void espAddHomeRoute(HttpRoute *parent)
{
    cchar   *source, *name, *path, *pattern, *prefix;

    prefix = parent->prefix ? parent->prefix : "";
    source = parent->sourceName;
    name = sjoin(prefix, "/home", NULL);
    path = stemplate("${CLIENT_DIR}/index.esp", parent->vars);
    pattern = sfmt("^%s(/)$", prefix);
    httpDefineRoute(parent, name, "GET,POST", pattern, path, source);
}


/*********************************** Directives *******************************/
/*
    Define an ESP Application
 */
PUBLIC int espApp(HttpRoute *route, cchar *dir, cchar *name, cchar *prefix, cchar *routeSet)
{
    EspRoute    *eroute;

    if ((eroute = getEroute(route)) == 0) {
        return MPR_ERR_MEMORY;
    }
    httpSetRouteDocuments(route, dir);
    httpSetRouteHome(route, dir);

    eroute->top = eroute;
    if (name) {
        eroute->appName = sclone(name);
    }
    espSetDefaultDirs(route);
    if (prefix) {
        if (*prefix != '/') {
            mprLog("warn esp", 0, "Prefix name should start with a \"/\"");
            prefix = sjoin("/", prefix, NULL);
        }
        prefix = stemplate(prefix, route->vars);
        httpSetRouteName(route, prefix);
        httpSetRoutePrefix(route, prefix);
        httpSetRoutePattern(route, sfmt("^%s", prefix), 0);
    } else {
        httpSetRouteName(route, sfmt("/%s", name));
    }
    httpAddRouteHandler(route, "espHandler", "esp");
    httpAddRouteIndex(route, "index.esp");
    httpAddRouteIndex(route, "index.html");

    httpSetRouteVar(route, "APP", name);
    httpSetRouteVar(route, "UAPP", stitle(name));

    if (httpLoadConfig(route, ME_ESP_PACKAGE) < 0) {
        return MPR_ERR_CANT_LOAD;
    }
    if (route->database && !eroute->edi) {
        if (espOpenDatabase(route, route->database) < 0) {
            mprLog("error esp", 0, "Cannot open database %s", route->database);
            return MPR_ERR_CANT_LOAD;
        }
    }
#if !ME_STATIC
    if (!eroute->skipApps) {
        MprJson     *preload, *item;
        cchar       *errMsg, *source;
        char        *kind;
        int         i;

        /*
            Note: the config parser pauses GC, so this will never yield
         */
        if (!loadApp(route, NULL)) {
            return MPR_ERR_CANT_LOAD;
        }
        if (!route->combine && (preload = mprGetJsonObj(route->config, "esp.preload")) != 0) {
            for (ITERATE_JSON(preload, item, i)) {
                source = stok(sclone(item->value), ":", &kind);
                if (!kind) kind = "controller";
                source = mprJoinPath(httpGetDir(route, "controllers"), source);
                if (espLoadModule(route, NULL, kind, source, &errMsg) < 0) {
                    mprLog("error esp", 0, "Cannot preload esp module %s. %s", source, errMsg);
                    return MPR_ERR_CANT_LOAD;
                }
            }
        }
    }
#endif
    if (routeSet) {
        httpAddRouteSet(route, routeSet);
    }
    return 0;
}


/*
    <EspApp
  or
    <EspApp
        auth=STORE
        database=DATABASE
        dir=DIR
        combine=true|false
        name=NAME
        prefix=PREFIX
        routes=ROUTES
 */
static int startEspAppDirective(MaState *state, cchar *key, cchar *value)
{
    HttpRoute   *route;
    cchar       *auth, *database, *name, *prefix, *dir, *routeSet, *combine;
    char        *option, *ovalue, *tok;

    dir = ".";
    routeSet = 0;
    combine = 0;
    prefix = 0;
    database = 0;
    auth = 0;
    name = 0;

    if (scontains(value, "=")) {
        for (option = maGetNextArg(sclone(value), &tok); option; option = maGetNextArg(tok, &tok)) {
            option = stok(option, " =\t,", &ovalue);
            ovalue = strim(ovalue, "\"'", MPR_TRIM_BOTH);
            if (smatch(option, "auth")) {
                auth = ovalue;
            } else if (smatch(option, "database")) {
                database = ovalue;
            } else if (smatch(option, "dir")) {
                dir = ovalue;
            } else if (smatch(option, "combine")) {
                combine = ovalue;
#if DEPRECATED || 1
            } else if (smatch(option, "combined")) {
                combine = ovalue;
#endif
            } else if (smatch(option, "name")) {
                name = ovalue;
            } else if (smatch(option, "prefix")) {
                prefix = ovalue;
            } else if (smatch(option, "routes")) {
                routeSet = ovalue;
            } else {
                mprLog("error esp", 0, "Unknown EspApp option \"%s\"", option);
            }
        }
    }
    if (mprSamePath(state->route->documents, dir)) {
        /*
            Can use existing route as it has the same prefix and documents directory.
         */
        route = state->route;
    } else {
        route = httpCreateInheritedRoute(state->route);
    }
    state->route = route;
    if (auth) {
        if (httpSetAuthStore(route->auth, auth) < 0) {
            mprLog("error esp", 0, "The %s AuthStore is not available on this platform", auth);
            return MPR_ERR_BAD_STATE;
        }
    }
    if (combine) {
        route->combine = scaselessmatch(combine, "true") || smatch(combine, "1");
    }
    if (database) {
        if (espDbDirective(state, key, database) < 0) {
            return MPR_ERR_BAD_STATE;
        }
    }
    if (espApp(route, dir, name, prefix, routeSet) < 0) {
        return MPR_ERR_CANT_CREATE;
    }
    if (prefix) {
        espSetConfig(route, "esp.appPrefix", prefix);
    }
    return 0;
}


static int finishEspAppDirective(MaState *state, cchar *key, cchar *value)
{
    HttpRoute   *route;

    /*
        The order of route finalization will be from the inside. Route finalization causes the route to be added
        to the enclosing host. This ensures that nested routes are defined BEFORE outer/enclosing routes.
     */
    route = state->route;
    if (route != state->prev->route) {
        httpFinalizeRoute(route);
    }
    return 0;
}


/*
    <EspApp>
 */
static int openEspAppDirective(MaState *state, cchar *key, cchar *value)
{
    state = maPushState(state);
    return startEspAppDirective(state, key, value);
}


/*
    </EspApp>
 */
static int closeEspAppDirective(MaState *state, cchar *key, cchar *value)
{
    if (finishEspAppDirective(state, key, value) < 0) {
        return MPR_ERR_BAD_STATE;
    }
    maPopState(state);
    return 0;
}


/*
    see openEspAppDirective
 */
static int espAppDirective(MaState *state, cchar *key, cchar *value)
{
    state = maPushState(state);
    if (startEspAppDirective(state, key, value) < 0) {
        return MPR_ERR_BAD_STATE;
    }
    if (finishEspAppDirective(state, key, value) < 0) {
        return MPR_ERR_BAD_STATE;
    }
    maPopState(state);
    return 0;
}


/*
    EspCompile template
 */
static int espCompileDirective(MaState *state, cchar *key, cchar *value)
{
    EspRoute    *eroute;

    if ((eroute = getEroute(state->route)) == 0) {
        return MPR_ERR_MEMORY;
    }
    eroute->compile = sclone(value);
    return 0;
}


PUBLIC int espOpenDatabase(HttpRoute *route, cchar *spec)
{
    EspRoute    *eroute;
    char        *provider, *path, *dir;
    int         flags;

    eroute = route->eroute;
    if (eroute->edi) {
        return 0;
    }
    flags = EDI_CREATE | EDI_AUTO_SAVE;
    if (smatch(spec, "default")) {
#if ME_COM_SQLITE
        spec = sfmt("sdb://%s.sdb", eroute->appName);
#elif ME_COM_MDB
        spec = sfmt("mdb://%s.mdb", eroute->appName);
#endif
    }
    provider = stok(sclone(spec), "://", &path);
    if (provider == 0 || path == 0) {
        return MPR_ERR_BAD_ARGS;
    }
    path = mprJoinPath(httpGetDir(route, "db"), path);
    dir = mprGetPathDir(path);
    if (!mprPathExists(dir, X_OK)) {
        mprMakeDir(dir, 0755, -1, -1, 1);
    }
    if ((eroute->edi = ediOpen(mprGetRelPath(path, NULL), provider, flags)) == 0) {
        return MPR_ERR_CANT_OPEN;
    }
    route->database = sclone(spec);
    return 0;
}


/*
    EspDb provider://database
 */
static int espDbDirective(MaState *state, cchar *key, cchar *value)
{
    EspRoute    *eroute;

    if ((eroute = getEroute(state->route)) == 0) {
        return MPR_ERR_MEMORY;
    }
    if (espOpenDatabase(state->route, value) < 0) {
        if (!(state->flags & MA_PARSE_NON_SERVER)) {
            mprLog("error esp", 0, "Cannot open database '%s'. Use: provider://database", value);
            return MPR_ERR_CANT_OPEN;
        }
    }
    return 0;
}


PUBLIC void espSetDefaultDirs(HttpRoute *route)
{
    httpSetDir(route, "app", "client/app");
    httpSetDir(route, "cache", 0);
    httpSetDir(route, "client", 0);
    httpSetDir(route, "controllers", 0);
    httpSetDir(route, "db", 0);
    httpSetDir(route, "layouts", 0);
    httpSetDir(route, "lib", "client/lib");
    httpSetDir(route, "paks", "paks");
    httpSetDir(route, "src", 0);
    httpSetDir(route, "views", "client/app");

    /*  Client relative LIB for client.scripts */
    httpSetRouteVar(route, "LIB", "lib");

#if TODO
    //  missing upload
    httpSetRouteUploadDir(route, httpMakePath(route, 0, value));
#endif
}


/*
    EspDir key path
 */
static int espDirDirective(MaState *state, cchar *key, cchar *value)
{
    EspRoute    *eroute;
    char        *name, *path;

    if ((eroute = getEroute(state->route)) == 0) {
        return MPR_ERR_MEMORY;
    }
    if (!maTokenize(state, value, "%S ?S", &name, &path)) {
        return MPR_ERR_BAD_SYNTAX;
    }
#if DEPRECATED || 1
    if (smatch(name, "mvc")) {
        espSetDefaultDirs(state->route);
    } else
#endif
    {
        path = stemplate(path, state->route->vars);
        path = stemplate(mprJoinPath(state->route->home, path), state->route->vars);
        httpSetDir(state->route, name, path);
    }
    return 0;
}


/*
    Define Visual Studio environment if not already present
 */
static void defineVisualStudioEnv(MaState *state)
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
        espEnvDirective(state, "EspEnv",
            "LIB \"${WINSDK}\\LIB\\${WINVER}\\um\\x64;${WINSDK}\\LIB\\x64;${VS}\\VC\\lib\\amd64\"");
        if (is64BitSystem) {
            espEnvDirective(state, "EspEnv",
                "PATH \"${VS}\\Common7\\IDE;${VS}\\VC\\bin\\amd64;${VS}\\Common7\\Tools;${VS}\\SDK\\v3.5\\bin;"
                "${VS}\\VC\\VCPackages;${WINSDK}\\bin\\x64\"");

        } else {
            /* Cross building on x86 for 64-bit */
            espEnvDirective(state, "EspEnv",
                "PATH \"${VS}\\Common7\\IDE;${VS}\\VC\\bin\\x86_amd64;"
                "${VS}\\Common7\\Tools;${VS}\\SDK\\v3.5\\bin;${VS}\\VC\\VCPackages;${WINSDK}\\bin\\x86\"");
        }

    } else if (scontains(http->platform, "-arm-")) {
        /* Cross building on x86 for arm. No winsdk 7 support for arm */
        espEnvDirective(state, "EspEnv", "LIB \"${WINSDK}\\LIB\\${WINVER}\\um\\arm;${VS}\\VC\\lib\\arm\"");
        espEnvDirective(state, "EspEnv", "PATH \"${VS}\\Common7\\IDE;${VS}\\VC\\bin\\x86_arm;${VS}\\Common7\\Tools;"
            "${VS}\\SDK\\v3.5\\bin;${VS}\\VC\\VCPackages;${WINSDK}\\bin\\arm\"");

    } else {
        /* Building for X86 */
        espEnvDirective(state, "EspEnv", "LIB \"${WINSDK}\\LIB\\${WINVER}\\um\\x86;${WINSDK}\\LIB\\x86;"
            "${WINSDK}\\LIB;${VS}\\VC\\lib\"");
        espEnvDirective(state, "EspEnv", "PATH \"${VS}\\Common7\\IDE;${VS}\\VC\\bin;${VS}\\Common7\\Tools;"
            "${VS}\\SDK\\v3.5\\bin;${VS}\\VC\\VCPackages;${WINSDK}\\bin\"");
    }
    espEnvDirective(state, "EspEnv", "INCLUDE \"${VS}\\VC\\INCLUDE;${WINSDK}\\include;${WINSDK}\\include\\um;"
        "${WINSDK}\\include\\shared\"");
}


/*
    EspEnv var string
    This defines an environment variable setting. It is defined only when commands for this route are executed.
 */
static int espEnvDirective(MaState *state, cchar *key, cchar *value)
{
    EspRoute    *eroute;
    char        *ekey, *evalue;

    if ((eroute = getEroute(state->route)) == 0) {
        return MPR_ERR_MEMORY;
    }
    if (!maTokenize(state, value, "%S ?S", &ekey, &evalue)) {
        return MPR_ERR_BAD_SYNTAX;
    }
    if (eroute->env == 0) {
        eroute->env = mprCreateHash(-1, MPR_HASH_STABLE);
    }
    evalue = espExpandCommand(state->route, evalue, "", "");
    if (scaselessmatch(ekey, "VisualStudio")) {
        defineVisualStudioEnv(state);
    } else {
        mprAddKey(eroute->env, ekey, evalue);
    }
    if (scaselessmatch(ekey, "PATH")) {
        if (eroute->searchPath) {
            eroute->searchPath = sclone(evalue);
        } else {
            eroute->searchPath = sjoin(eroute->searchPath, MPR_SEARCH_SEP, evalue, NULL);
        }
    }
    return 0;
}


/*
    EspKeepSource on|off
 */
static int espKeepSourceDirective(MaState *state, cchar *key, cchar *value)
{
    bool        on;

    if (!maTokenize(state, value, "%B", &on)) {
        return MPR_ERR_BAD_SYNTAX;
    }
    state->route->keepSource = on;
    return 0;
}


/*
    EspLink template
 */
static int espLinkDirective(MaState *state, cchar *key, cchar *value)
{
    EspRoute    *eroute;

    if ((eroute = getEroute(state->route)) == 0) {
        return MPR_ERR_MEMORY;
    }
    eroute->link = sclone(value);
    return 0;
}


/*
    Initialize and load a statically linked ESP module
 */
PUBLIC int espStaticInitialize(EspModuleEntry entry, cchar *appName, cchar *routeName)
{
    HttpRoute   *route;

    if ((route = httpLookupRoute(NULL, routeName)) == 0) {
        mprLog("error esp", 0, "Cannot find route %s", routeName);
        return MPR_ERR_CANT_ACCESS;
    }
    return (entry)(route, NULL);
}


/*
    EspPermResource [resource ...]
 */
static int espPermResourceDirective(MaState *state, cchar *key, cchar *value)
{
    char        *name, *next;

    if (value == 0 || *value == '\0') {
        httpAddPermResource(state->route, state->route->serverPrefix, "{controller}");
    } else {
        name = stok(sclone(value), ", \t\r\n", &next);
        while (name) {
            httpAddPermResource(state->route, state->route->serverPrefix, name);
            name = stok(NULL, ", \t\r\n", &next);
        }
    }
    return 0;
}

/*
    EspResource [resource ...]
 */
static int espResourceDirective(MaState *state, cchar *key, cchar *value)
{
    char        *name, *next;

    if (value == 0 || *value == '\0') {
        httpAddResource(state->route, state->route->serverPrefix, "{controller}");
    } else {
        name = stok(sclone(value), ", \t\r\n", &next);
        while (name) {
            httpAddResource(state->route, state->route->serverPrefix, name);
            name = stok(NULL, ", \t\r\n", &next);
        }
    }
    return 0;
}


/*
    EspResourceGroup [resource ...]
 */
static int espResourceGroupDirective(MaState *state, cchar *key, cchar *value)
{
    char        *name, *next;

    if (value == 0 || *value == '\0') {
        httpAddResourceGroup(state->route, state->route->serverPrefix, "{controller}");
    } else {
        name = stok(sclone(value), ", \t\r\n", &next);
        while (name) {
            httpAddResourceGroup(state->route, state->route->serverPrefix, name);
            name = stok(NULL, ", \t\r\n", &next);
        }
    }
    return 0;
}


/*
    EspRoute
        methods=METHODS
        name=NAME
        prefix=PREFIX
        source=SOURCE
        target=TARGET
 */
static int espRouteDirective(MaState *state, cchar *key, cchar *value)
{
    EspRoute    *eroute;
    HttpRoute   *route;
    cchar       *methods, *name, *prefix, *source, *target;
    char        *option, *ovalue, *tok;

    prefix = 0;
    name = 0;
    source = 0;
    target = 0;
    methods = "GET";

    if (scontains(value, "=")) {
        for (option = maGetNextArg(sclone(value), &tok); option; option = maGetNextArg(tok, &tok)) {
            option = stok(option, "=,", &ovalue);
            ovalue = strim(ovalue, "\"'", MPR_TRIM_BOTH);
            if (smatch(option, "methods")) {
                methods = ovalue;
            } else if (smatch(option, "name")) {
                name = ovalue;
            } else if (smatch(option, "prefix")) {
                prefix = ovalue;
            } else if (smatch(option, "source")) {
                source = ovalue;
            } else if (smatch(option, "target")) {
                target = ovalue;
            } else {
                mprLog("error esp", 0, "Unknown EspRoute option \"%s\"", option);
            }
        }
    }
    if (!prefix || !target) {
        return MPR_ERR_BAD_SYNTAX;
    }
    if (target == 0 || *target == 0) {
        target = "$&";
    }
    target = stemplate(target, state->route->vars);
    if ((route = httpDefineRoute(state->route, name, methods, prefix, target, source)) == 0) {
        return MPR_ERR_CANT_CREATE;
    }
    httpSetRouteHandler(route, "espHandler");
    if ((eroute = getEroute(route)) == 0) {
        return MPR_ERR_MEMORY;
    }
    if (name) {
        eroute->appName = sclone(name);
    }
    return 0;
}


PUBLIC int espBindProc(HttpRoute *parent, cchar *pattern, void *proc)
{
    HttpRoute   *route;

    if ((route = httpDefineRoute(parent, pattern, "ALL", pattern, "$&", "unused")) == 0) {
        return MPR_ERR_CANT_CREATE;
    }
    httpSetRouteHandler(route, "espHandler");

    route->update = 0;
    espDefineAction(route, pattern, proc);
    return 0;
}


/*
    EspRouteSet kind
 */
static int espRouteSetDirective(MaState *state, cchar *key, cchar *value)
{
    EspRoute    *eroute;
    char        *kind;

    if ((eroute = getEroute(state->route)) == 0) {
        return MPR_ERR_MEMORY;
    }
    if (!maTokenize(state, value, "%S", &kind)) {
        return MPR_ERR_BAD_SYNTAX;
    }
    httpAddRouteSet(state->route, kind);
    return 0;
}


/*
    EspUpdate on|off
 */
static int espUpdateDirective(MaState *state, cchar *key, cchar *value)
{
    bool        on;

    if (!maTokenize(state, value, "%B", &on)) {
        return MPR_ERR_BAD_SYNTAX;
    }
    state->route->update = on;
    return 0;
}

/************************************ Init ************************************/
/*
    Loadable module configuration
 */
PUBLIC int maEspHandlerInit(Http *http, MprModule *module)
{
    HttpStage   *handler;
    MaAppweb    *appweb;
    cchar       *path;

    appweb = httpGetContext(http);

    if ((handler = httpCreateHandler(http, "espHandler", module)) == 0) {
        return MPR_ERR_CANT_CREATE;
    }
    http->espHandler = handler;
    handler->open = openEsp;
    handler->close = closeEsp;
    handler->start = startEsp;
    if ((esp = mprAllocObj(Esp, manageEsp)) == 0) {
        return MPR_ERR_MEMORY;
    }
    handler->stageData = esp;
    MPR->espService = esp;
    esp->mutex = mprCreateLock();
    esp->local = mprCreateThreadLocal();
    if (module) {
        mprSetModuleFinalizer(module, unloadEsp);
    }
    /* Thread-safe */
    if ((esp->views = mprCreateHash(-1, MPR_HASH_STATIC_VALUES)) == 0) {
        return 0;
    }
    if ((esp->actions = mprCreateHash(-1, MPR_HASH_STATIC_VALUES)) == 0) {
        return 0;
    }
    if (espInitParser() < 0) {
        return 0;
    }
    /*
        Add appweb configuration file directives
     */
    maAddDirective(appweb, "EspApp", espAppDirective);
    maAddDirective(appweb, "<EspApp", openEspAppDirective);
    maAddDirective(appweb, "</EspApp", closeEspAppDirective);
    maAddDirective(appweb, "EspCompile", espCompileDirective);
    maAddDirective(appweb, "EspDb", espDbDirective);
    maAddDirective(appweb, "EspDir", espDirDirective);
    maAddDirective(appweb, "EspEnv", espEnvDirective);
    maAddDirective(appweb, "EspKeepSource", espKeepSourceDirective);
    maAddDirective(appweb, "EspLink", espLinkDirective);
    maAddDirective(appweb, "EspPermResource", espPermResourceDirective);
    maAddDirective(appweb, "EspResource", espResourceDirective);
    maAddDirective(appweb, "EspResourceGroup", espResourceGroupDirective);
    maAddDirective(appweb, "EspRoute", espRouteDirective);
    maAddDirective(appweb, "EspRouteSet", espRouteSetDirective);
    maAddDirective(appweb, "EspUpdate", espUpdateDirective);
    if ((esp->ediService = ediCreateService()) == 0) {
        return 0;
    }
#if ME_COM_MDB
    /* Memory database */
    mdbInit();
#endif
#if ME_COM_SQLITE
    sdbInit();
#endif
    /*
        Load the esp.conf directives to compile esp
     */
    path = mprJoinPath(mprGetAppDir(), "esp.conf");
    if (mprPathExists(path, R_OK) && (http->platformDir || httpSetPlatformDir(0) == 0)) {
        if (maParseFile(NULL, mprJoinPath(mprGetAppDir(), "esp.conf")) < 0) {
            mprLog("error esp", 0, "Cannot parse %s", path);
            return MPR_ERR_CANT_OPEN;
        }
        esp->canCompile = 1;
    }
    return 0;
}


static int unloadEsp(MprModule *mp)
{
    HttpStage   *stage;

    if (esp->inUse) {
       return MPR_ERR_BUSY;
    }
    if (mprIsStopping()) {
        return 0;
    }
    if ((stage = httpLookupStage(MPR->httpService, mp->name)) != 0) {
        stage->flags |= HTTP_STAGE_UNLOADED;
    }
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
