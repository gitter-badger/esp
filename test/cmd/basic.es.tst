/*
    basic.tst - Basic http tests
 */

require support

let result = http("/index.html")
http("/index.html").contains("Hello /index.html")
