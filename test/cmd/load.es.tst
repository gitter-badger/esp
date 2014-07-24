/*
    load.tst - Load tests
 */

require support

if (tget('TM_DEPTH', 0) > 2) {
    http("-i 2000 /index.html")
    http("-i 2000 /big.txt")
}
