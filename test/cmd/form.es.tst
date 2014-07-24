/*
    form.tst - Test forms
 */
App.exit(0)

require support

//  Form data
data = http("--form 'name=John+Smith&address=300+Park+Avenue' /form.ejs")
ttrue(data.contains('"address": "300 Park Avenue"'))
ttrue(data.contains('"name": "John Smith"'))

//  Form data with a cookie
data = http("--cookie 'test-id=12341234; $domain=site.com; $path=/dir/' /form.ejs")
ttrue(data.contains('"test-id": '))
ttrue(data.contains('"name": "test-id",'))
ttrue(data.contains('"domain": "site.com",'))
ttrue(data.contains('"path": "/dir/",'))
