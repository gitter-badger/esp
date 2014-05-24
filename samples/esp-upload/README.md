ESP Upload Sample
===

This sample shows how to configure ESP for file upload.

The sample includes an upload web form: web/upload/upload-form.html. This form will
post the uploaded file to the web/upload/upload.esp page.

For security, file upload is restricted to URIs starting with /upload.

Requirements
---
* [ESP](http://embedthis.com/downloads/esp/download.esp)

To run:
---
    esp

The server listens on port 4000. Browse to: 
 
     http://localhost:4000/upload/upload-form.html

Code:
---
* [upload-form.html](upload-form.html) - File upload form
* [upload.esp](upload.esp) - ESP page to receive the uploaded file
* [cache](cache) - Compiled ESP modules

Documentation:
---
* [ESP Documentation](http://embedthis.com/products/esp/doc/index.html)
* [File Upload)(http://embedthis.com/products/esp/doc/guide/esp/users/uploading.html)
* [ESP Configuration](http://embedthis.com/products/esp/doc/guide/esp/users/config.html)
* [ESP APIs](http://embedthis.com/products/esp/doc/api/esp.html)
* [ESP Guide](http://embedthis.com/products/esp/doc/guide/esp/users/index.html)
* [ESP Overview](http://embedthis.com/products/esp/doc/guide/esp/users/using.html)

See Also:
---
* [esp-html-mvc - ESP HTML MVC Application](../esp-html-mvc/README.md)
* [esp-controller - Creating ESP controllers](../esp-controller/README.md)
* [esp-html-mvc - ESP MVC Application](../esp-html-mvc/README.md)
* [esp-page - Serving ESP pages](../esp-page/README.md)
