/*
    ranges.tst - Test http with ranges
 */

require support

//  Ranges
ttrue(http("--range 0-4 /numbers.html") == "01234")
ttrue(http("--range -5 /numbers.html") == "5678")
