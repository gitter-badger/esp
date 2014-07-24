/*
    put.tst - Test the put command
 */

require support

cleanDir('web/tmp')

//  PUT file
http('test.dat /tmp/day.tmp')
ttrue(Path('web/tmp/day.tmp').exists)

//  PUT files
http(Path('.').files('*.tst').join(' ') + ' /tmp/')
ttrue(Path('web/tmp/basic.es.tst').exists)

cleanDir('web/tmp')
