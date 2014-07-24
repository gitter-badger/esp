/*
    methods.tst - Test various http methods
 */

require support

let data

data = http('-s -q -m TRACE /index.html')
ttrue(data.contains('HTTP/1.1 405'))

data = http('-s -q -m OPTIONS /trace/index.html')
ttrue(data.contains('HTTP/1.1 200'))

data = http('-s -q -m TRACE /trace/index.html')
ttrue(data.contains('HTTP/1.1 200'))
