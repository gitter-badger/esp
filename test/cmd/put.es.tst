/*
    put.tst - Test the put command
 */

require support

cleanDir('documents/tmp')

//  PUT file
http('test.dat /tmp/day.tmp')
ttrue(Path('documents/tmp/day.tmp').exists)

//  PUT files
http(Path('.').files('*.tst').join(' ') + ' /tmp/')
ttrue(Path('documents/tmp/basic.es.tst').exists)

cleanDir('documents/tmp')
