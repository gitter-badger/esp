ESP Layout Sample
===

This sample shows how to use ESP layout pages with stand-alone ESP pages.

The page to be served, index.esp specifies the desired layout page, "default.esp".
It does this with the <%@ layout "file" %> directive.

Requirements
---
* [ESP](https://embedthis.com/esp/download.html)

To run:
---
    esp run

The server listens on port 4000. Browse to: 
 
     http://localhost:4000/index.esp

Code:
---
* [index.esp](index.esp) - ESP page to serve. Uses layout.esp as a template.
* [layouts/layout.esp](index.esp) - ESP layout template

Documentation:
---
* [ESP Documentation](https://embedthis.com/esp/doc/index.html)
* [ESP APIs](https://embedthis.com/esp/doc/api/esp.html)
* [ESP Guide](https://embedthis.com/esp/doc/users/index.html)
* [ESP Overview](https://embedthis.com/esp/doc/users/using.html)

See Also:
---
* [esp-html-mvc - ESP MVC Application](../esp-html-mvc/README.md)
* [esp-controller - ESP Page](../esp-controller/README.md)
* [esp-page - ESP Page](../esp-page/README.md)
