/*
    get.tst - Test http get 
 */

require support

//  Basic get
data = http("/numbers.txt")
ttrue(data.startsWith("012345678"))
ttrue(data.endsWith("END"))
