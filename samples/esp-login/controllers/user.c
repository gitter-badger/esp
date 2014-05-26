/*
    user.c - User login
 */
#include "esp.h"

static void loginUser() {
    if (httpLogin(getConn(), param("username"), param("password"))) {
        redirect("/index.esp");
    } else {
        feedback("error", "Invalid Login");
        redirect("/login.esp");
    }       
}

static void logoutUser() {                                                                             
    httpLogout(getConn());
    redirect("/login.esp");
}

static void commonController(HttpConn *conn)
{
    cchar   *uri;

    if (!httpLoggedIn(conn)) {
        uri = getUri();
        if (smatch(uri, "/login.esp") || smatch(uri, "/user/login") || smatch(uri, "/user/logout")) {
            return;
        }
        httpError(conn, HTTP_CODE_UNAUTHORIZED, "Access Denied. Login required");
    }
}

ESP_EXPORT int esp_controller_login_user(HttpRoute *route) 
{
    espDefineBase(route, commonController);
    espDefineAction(route, "user-login", loginUser);
    espDefineAction(route, "user-logout", logoutUser);
    return 0;
}
