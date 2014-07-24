/*
    auth.tst - Test authentication
 */
require support

http("--user 'joshua:pass1' /auth/basic/basic.html")
http("--user 'joshua' --password 'pass1' /auth/basic/basic.html")
