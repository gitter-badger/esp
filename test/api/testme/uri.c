/**
    uri.c.tst - tests for URIs

    Copyright (c) All Rights Reserved. See details at the end of the file.
 */

/********************************** Includes **********************************/

#include    "testme.h"
#include    "http.h"

/************************************ Code ************************************/

static void normalize(char *uri, char *expectedUri)
{
    char    *validated;

    validated = httpNormalizeUriPath(uri);
    if (smatch(expectedUri, validated)) {
        ttrue(1);
    } else {
        ttrue(0);
        tinfo("Uri \"%s\" validated to \"%s\" instead of \"%s\"", uri, validated, expectedUri);
    }
}


static void validate(char *uri, char *expectedUri)
{
    cchar   *validated;

    validated = httpValidateUriPath(uri);
    if (smatch(expectedUri, validated)) {
        ttrue(1);
    } else {
        ttrue(0);
        tinfo("Uri \"%s\" validated to \"%s\" instead of \"%s\"", uri, validated, expectedUri);
    }
}


static bool checkUri(HttpUri *uri, cchar *expected)
{
    cchar   *s;

    s = sfmt("%s-%s-%d-%s-%s-%s-%s", uri->scheme, uri->host, uri->port, uri->path, uri->ext, uri->reference, uri->query);
    if (smatch(s, expected)) {
        ttrue(1);
    } else {
        ttrue(0);
        tinfo("EXPECTED: %s\nURI:      %s", expected, s);
    }
    return smatch(s, expected);
}


static void testCreateUri()
{
    HttpUri     *uri;

    uri = httpCreateUri(NULL, 0);
    checkUri(uri, "null-null-0-null-null-null-null");

    uri = httpCreateUri("", 0);
    checkUri(uri, "null-null-0-null-null-null-null");

    uri = httpCreateUri("http", 0);
    checkUri(uri, "null-null-0-http-null-null-null");

    uri = httpCreateUri("https", 0);
    checkUri(uri, "null-null-0-https-null-null-null");
    
    uri = httpCreateUri("http://", 0);
    checkUri(uri, "http-null-0-null-null-null-null");

    uri = httpCreateUri("https://", 0);
    checkUri(uri, "https-null-0-null-null-null-null");

    uri = httpCreateUri("http://:8080/", 0);
    checkUri(uri, "http-null-8080-/-null-null-null");

    uri = httpCreateUri("http://:8080", 0);
    checkUri(uri, "http-null-8080-null-null-null-null");

    uri = httpCreateUri("http:///", 0);
    checkUri(uri, "http-null-0-/-null-null-null");

    uri = httpCreateUri("http://localhost", 0);
    checkUri(uri, "http-localhost-0-null-null-null-null");

    uri = httpCreateUri("http://localhost/", 0);
    checkUri(uri, "http-localhost-0-/-null-null-null");

    uri = httpCreateUri("http://[::]", 0);
    checkUri(uri, "http-::-0-null-null-null-null");

    uri = httpCreateUri("http://[::]/", 0);
    checkUri(uri, "http-::-0-/-null-null-null");

    uri = httpCreateUri("http://[::]:8080", 0);
    checkUri(uri, "http-::-8080-null-null-null-null");

    uri = httpCreateUri("http://[::]:8080/", 0);
    checkUri(uri, "http-::-8080-/-null-null-null");

    uri = httpCreateUri("http://localhost/path", 0);
    checkUri(uri, "http-localhost-0-/path-null-null-null");

    uri = httpCreateUri("http://localhost/path.txt", 0);
    checkUri(uri, "http-localhost-0-/path.txt-txt-null-null");

    uri = httpCreateUri("http://localhost/path.txt?query", 0);
    checkUri(uri, "http-localhost-0-/path.txt-txt-null-query");

    uri = httpCreateUri("http://localhost/path.txt?query#ref", 0);
    checkUri(uri, "http-localhost-0-/path.txt-txt-null-query#ref");

    uri = httpCreateUri("http://localhost/path.txt#ref?query", 0);
    checkUri(uri, "http-localhost-0-/path.txt-txt-ref-query");

    uri = httpCreateUri("http://localhost/path.txt#ref/extra", 0);
    checkUri(uri, "http-localhost-0-/path.txt-txt-ref/extra-null");

    uri = httpCreateUri("http://localhost/path.txt#ref/extra?query", 0);
    checkUri(uri, "http-localhost-0-/path.txt-txt-ref/extra-query");

    uri = httpCreateUri(":4100", 0);
    checkUri(uri, "null-null-4100-null-null-null-null");

    uri = httpCreateUri(":4100/path", 0);
    checkUri(uri, "null-null-4100-/path-null-null-null");

    uri = httpCreateUri("http:/", 0);
    checkUri(uri, "null-http-0-/-null-null-null");

    uri = httpCreateUri("http://:/", 0);
    checkUri(uri, "http-null-0-/-null-null-null");

    uri = httpCreateUri("http://:", 0);
    checkUri(uri, "http-null-0-null-null-null-null");

    uri = httpCreateUri("http://localhost:", 0);
    checkUri(uri, "http-localhost-0-null-null-null-null");
    
    uri = httpCreateUri("http://local#host/", 0);
    checkUri(uri, "http-local-0-null-null-host/-null");

    uri = httpCreateUri("http://local?host/", 0);
    checkUri(uri, "http-local-0-null-null-null-host/");

    uri = httpCreateUri("http://local host/", 0);
    checkUri(uri, "http-local host-0-/-null-null-null");

    uri = httpCreateUri("http://localhost/long path", 0);
    checkUri(uri, "http-localhost-0-/long path-null-null-null");

    uri = httpCreateUri("", HTTP_COMPLETE_URI);
    checkUri(uri, "http-localhost-80-/-null-null-null");
}


static void testNormalizeUri()
{
    /*
        Note that normalize permits relative URLs
     */
    normalize("", "");
    normalize("/", "/");
    normalize("..", "");
    normalize("../", "");
    normalize("/..", "");

    normalize("./", "");
    normalize("./.", "");
    normalize("././", "");

    normalize("a", "a");
    normalize("/a", "/a");
    normalize("a/", "a/");
    normalize("../a", "a");
    normalize("/a/..", "/");
    normalize("/a/../", "/");
    normalize("a/..", "");
    normalize("/../a", "a");
    normalize("../../a", "a");
    normalize("../a/b/..", "a");

    normalize("/b/a", "/b/a");
    normalize("/b/../a", "/a");
    normalize("/a/../b/..", "/");

    normalize("/a/./", "/a/");
    normalize("/a/./.", "/a/");
    normalize("/a/././", "/a/");
    normalize("/a/.", "/a/");

    normalize("/*a////b/", "/*a/b/");
    normalize("/*a/////b/", "/*a/b/");

    normalize("\\a\\b\\", "\\a\\b\\");

    normalize("/..appweb.conf", "/..appweb.conf");
    normalize("/..\\appweb.conf", "/..\\appweb.conf");
}


static void testValidateUri()
{
    /*
        Note that validate only accepts absolute URLs that begin with "/"
     */

    validate("", 0);
    validate("/", "/");
    validate("..", 0);
    validate("../", 0);
    validate("/..", 0);

    validate("./", 0);
    validate("./.", 0);
    validate("././", 0);

    validate("a", 0);
    validate("/a", "/a");
    validate("a/", 0);
    validate("../a", 0);
    validate("/a/..", "/");
    validate("/a/../", "/");
    validate("a/..", 0);
    validate("/../a", 0);
    validate("../../a", 0);
    validate("../a/b/..", 0);

    validate("/b/a", "/b/a");
    validate("/b/../a", "/a");
    validate("/a/../b/..", "/");

    validate("/a/./", "/a/");
    validate("/a/./.", "/a/");
    validate("/a/././", "/a/");
    validate("/a/.", "/a/");

    validate("/*a////b/", "/*a/b/");
    validate("/*a/////b/", "/*a/b/");

    validate("\\a\\b\\", 0);

    validate("/..\\appweb.conf", 0);
    validate("/\\appweb.conf", 0);
    validate("/..%5Cappweb.conf", "/..\\appweb.conf");

    /*
        Regression tests
     */
    validate("/extra%20long/a/..", "/extra long");
    validate("/extra%20long/../path/a/..", "/path");
}


int main(int argc, char **argv)
{
    mprCreate(argc, argv, 0);

    testCreateUri();
    testNormalizeUri();
    testValidateUri();
}

/*
    @copy   default
    
    Copyright (c) Embedthis Software LLC, 2003-2014. All Rights Reserved.
    Copyright (c) Michael O'Brien, 1993-2014. All Rights Reserved.
    
    This software is distributed under commercial and open source licenses.
    You may use the Embedthis Open Source license or you may acquire a
    commercial license from Embedthis Software. You agree to be fully bound
    by the terms of either license. Consult the LICENSE.md distributed with
    this software for full details and other copyrights.

    Local variables:
    tab-width: 4
    c-basic-offset: 4
    End:
    vim: sw=4 ts=4 expandtab

    @end
 */
