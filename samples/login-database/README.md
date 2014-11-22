login-database Sample
===

This sample shows how to configure a simple form-based login using ESP with passwords stored
in a user database. This sample uses the a web form for entering username and password credentials.

This sample uses:

* Passwords defined in a user database (mdb)
* Database definition and database migration for creating database and test data
* Https for encryption of traffic for login forms
* Redirection to a login page and logged out page
* Redirection to use https for login forms and http once logged in
* Self-signed certificate. You should obtain a real certificate.
* Login username and password entry via web form
* Automatic session creation and management
* Blowfish encryption for secure password hashing

Notes:
* This sample keeps the passwords in an application database package.json. The test password was created 
    by using mprMakePassword in the database migration under db/migrations.

* Session cookies are created to manage server-side session state storage and to optimize authentication.

* The sample creates three routes. A "public" route for the login form and required assets. This route
    does not employ authentication. A "web" route that requires authentication for web content. A
    "login" route for the login controller that processes the login and logout request.

Requirements
---
* [Download ESP](https://embedthis.com/esp/download.html)

To run:
---
    esp run

The server listens on port 4000 for HTTP traffic and 4443 for SSL. Browse to: 
 
     http://localhost:4000/

This will redirect to SSL (you will get a warning due to the self-signed certificate).
Continue and you will be prompted to login. The test username/password is:

    joshua/pass1

Code:
---
* cache - Directory for cached ESP pages
* controllers - Directory for controllers
* public - Web pages and resources accessible without authentication
* db/login.mdb - Database
* db/migrations/ - Database migrations to create schema and test data
* web - Web pages requiring authentication for access
* [web/index.esp](web/index.esp) - Home page
* [public/login.esp](public/login.esp) - Login page
* [controllers/user.c](controllers/user.c) - User login controller code
* [package.json](package.json) - ESP configuration file

Documentation:
---

* [ESP Documentation](https://embedthis.com/esp/doc/index.html)
* [ESP Configuration](https://embedthis.com/esp/doc/users/config.html)
