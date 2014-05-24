Esp-login Sample
===

This sample shows how to configure a simple form-based login using ESP. 
Note: this does not implement typical UI elements of warning the user, other than a basic alert.

This sample uses:

* SSL for encryption of traffic
* Redirection of all traffic over SSL
* Login authentication 
* Blowfish encryption for secure password hashing

This sample uses a self-signed certificate. In your application, you will need a real certificate.

Notes:
The password database is kept in a flat file called auth.conf. The password was created via:

    authpass --cipher blowfish --password pass5 auth.conf example.com ralph

Requirements
---
* [ESP](http://embedthis.com/downloads/esp/download.esp)

To run:
---
    esp run

The server listens on port 4000 for HTTP traffice and 4443 for SSL. Browse to: 
 
     http://localhost:4000/

This will redirect to SSL (you will get a warning due to the self-signed certificate).
Continue and you will be prompted to login. The test username/password is:

    ralph/pass5

Code:
---
* [server.c](server.c) - Main program
* [package.json](package.json) - ESP configuration file
* [self.crt](self.crt) - Self-signed test certificate
* [self.key](self.key) - Test private key
* [web](web) - Web content to serve
* [start.me](start.me) - MakeMe build instructions
* [cache](cache) - Directory for cached ESP pages

Documentation:
---
* [ESP Documentation](http://embedthis.com/products/esp/doc/index.html)
* [Chroot Directive](http://embedthis.com/products/esp/doc/guide/esp/users/dir/server.html#chroot)
* [Configuration Directives](http://embedthis.com/products/esp/doc/guide/esp/users/configuration.html#directives)
* [Sandbox Limits](http://embedthis.com/products/esp/doc/guide/esp/users/dir/sandbox.html)
* [Security Considerations](http://embedthis.com/products/esp/doc/guide/esp/users/security.html)
* [SSL in Appweb](http://embedthis.com/products/esp/doc/guide/esp/users/ssl.html)
* [User Authentication](http://embedthis.com/products/esp/doc/guide/esp/users/authentication.html)

See Also:
---
