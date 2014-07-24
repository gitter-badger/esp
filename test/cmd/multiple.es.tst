/*
    multiple.tst - Test multiple get commands
 */

require support

//  Multiple requests to test keep-alive
http("-i 300 /index.html")

//  Multiple requests to test keep-alive
http("--chunk 100 -i 300 /index.html")

