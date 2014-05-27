Esp-login Sample
===

This sample shows how to configure a simple form-based login using ESP. 
Note: this does not implement typical UI elements of warning the user, other than a basic alert.

This sample uses:

* SSL for encryption of traffic
* Self-signed certificate. You should obtain a real certificate.
* Redirection of all traffic over SSL
* Login authentication 
* Blowfish encryption for secure password hashing

Notes:
* This sample keeps the passwords in the package.json. The test password was created via:

    esp --password pass1 user add joshua user

* The sample is setup to use the "config" auth store which keeps the passwords in the package.json.
    If you wish to store passwords in a database, you will need to ........ 
* The sample uses the "form" auth type by default. 
    It can be configured to use the "basic" or "digest" authentication protocol by setting the
    app.http.auth.type to "basic" or "digest".

Requirements
---
* [ESP](http://embedthis.com/downloads/esp/download.esp)

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
* [index.esp](index.esp) - Home page
* [login.esp](login.esp) - Login page
* [controllers/user.c](controllers/user.c) - User login controller code
* [package.json](package.json) - ESP configuration file
* [self.crt](self.crt) - Self-signed test certificate
* [self.key](self.key) - Test private key
* cache - Directory for cached ESP pages

Documentation:
---
* [ESP Documentation](http://embedthis.com/products/esp/doc/index.html)
* [ESP Configuration](http://embedthis.com/products/esp/doc/guide/esp/users/config.html)
