/*
    empty.tst - Empty response
 */

require support

//  Empty get
data = http("/empty.html")
ttrue(data == "")

