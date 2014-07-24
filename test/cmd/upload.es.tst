/*
    upload.tst - Test http upload
 */

require support

let uploadDir = Path('web/tmp')

cleanDir(uploadDir)

data = http("--upload support.es.com /upload/uploadFile.html")
ttrue(data.contains('Upload Complete'))

for each (file in uploadDir) {
    ttrue(file.readString() == Path('support.es.com').readString())
    break
}
cleanDir(uploadDir)
