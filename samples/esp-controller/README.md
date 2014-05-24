ESP Controller Sample
===

This sample shows how to create and configure ESP controllers. The controller is in 
service.c. It registers one action that is run in response to the URI: /test/hello.

Requirements
---
* [ESP](http://embedthis.com/downloads/esp/download.esp)

To run:
---
    esp

The server listens on port 4000. Browse to: 
 
     http://localhost:4000/test/hello

This then returns "Hello World" to the client.

If you modify the service.c it will be automatically recompiled and reloaded when 
next accessed.

Code:
---
* [service.c](service.c) - ESP controller source

Documentation:
---
* [ESP Documentation](http://embedthis.com/products/sp/doc/index.html)
* [ESP Tour](http://embedthis.com/products/esp/doc/guide/esp/start/tour.html)
* [ESP Controllers](http://embedthis.com/products/esp/doc/guide/esp/users/controllers.html)
* [ESP APIs](http://embedthis.com/products/esp/doc/api/esp.html)
* [ESP Guide](http://embedthis.com/products/esp/doc/guide/esp/users/index.html)
* [ESP Overview](http://embedthis.com/products/esp/doc/guide/esp/users/using.html)

See Also:
---
* [esp-html-mvc - ESP HTML MMVC](../esp-html-mvc/README.md)
* [esp-layout - ESP Layouts](../esp-layout/README.md)
* [esp-page - Serving ESP pages](../esp-page/README.md)
