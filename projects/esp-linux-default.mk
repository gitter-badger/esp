#
#   esp-linux-default.mk -- Makefile to build Embedthis ESP for linux
#

PRODUCT            := esp
VERSION            := 0.9.0
PROFILE            := default
ARCH               := $(shell uname -m | sed 's/i.86/x86/;s/x86_64/x64/;s/arm.*/arm/;s/mips.*/mips/')
CC_ARCH            := $(shell echo $(ARCH) | sed 's/x86/i686/;s/x64/x86_64/')
OS                 := linux
CC                 := gcc
LD                 := link
CONFIG             := $(OS)-$(ARCH)-$(PROFILE)
LBIN               := $(CONFIG)/bin

BIT_COMP_APPWEB    := 1
BIT_COMP_CGI       := 0
BIT_COMP_DIR       := 0
BIT_COMP_EJS       := 1
BIT_COMP_EST       := 1
BIT_COMP_LIBEST    := 0
BIT_COMP_MATRIXSSL := 0
BIT_COMP_NANOSSL   := 0
BIT_COMP_OPENSSL   := 0
BIT_COMP_PCRE      := 1
BIT_COMP_PHP       := 0
BIT_COMP_SQLITE    := 1
BIT_COMP_SSL       := 1
BIT_COMP_ZLIB      := 1

ifeq ($(BIT_COMP_EST),1)
    BIT_COMP_SSL := 1
endif
ifeq ($(BIT_COMP_LIB),1)
    BIT_COMP_COMPILER := 1
endif
ifeq ($(BIT_COMP_MATRIXSSL),1)
    BIT_COMP_SSL := 1
endif
ifeq ($(BIT_COMP_NANOSSL),1)
    BIT_COMP_SSL := 1
endif
ifeq ($(BIT_COMP_OPENSSL),1)
    BIT_COMP_SSL := 1
endif
ifeq ($(BIT_COMP_SDB),1)
    BIT_COMP_SQLITE := 1
endif

BIT_COMP_APPWEB_PATH      := appweb
BIT_COMP_BITOS_PATH       := bitos
BIT_COMP_CGI_PATH         := cgi
BIT_COMP_COMPILER_PATH    := gcc
BIT_COMP_DIR_PATH         := dir
BIT_COMP_DOXYGEN_PATH     := doxygen
BIT_COMP_DSI_PATH         := dsi
BIT_COMP_EJS_PATH         := ejs
BIT_COMP_ESP_PATH         := esp
BIT_COMP_EST_PATH         := est
BIT_COMP_GZIP_PATH        := gzip
BIT_COMP_HTMLMIN_PATH     := htmlmin
BIT_COMP_HTTP_PATH        := http
BIT_COMP_LIB_PATH         := ar
BIT_COMP_LINK_PATH        := link
BIT_COMP_MAN_PATH         := man
BIT_COMP_MAN2HTML_PATH    := man2html
BIT_COMP_MATRIXSSL_PATH   := /usr/src/matrixssl
BIT_COMP_MDB_PATH         := mdb
BIT_COMP_MPR_PATH         := mpr
BIT_COMP_NANOSSL_PATH     := /usr/src/nanossl
BIT_COMP_OPENSSL_PATH     := /usr/src/openssl
BIT_COMP_PAK_PATH         := pak
BIT_COMP_PCRE_PATH        := pcre
BIT_COMP_PHP_PATH         := php
BIT_COMP_PMAKER_PATH      := pmaker
BIT_COMP_RECESS_PATH      := recess
BIT_COMP_SDB_PATH         := sdb
BIT_COMP_SQLITE_PATH      := sqlite
BIT_COMP_SSL_PATH         := ssl
BIT_COMP_UGLIFYJS_PATH    := uglifyjs
BIT_COMP_UTEST_PATH       := utest
BIT_COMP_ZIP_PATH         := zip

CFLAGS             += -fPIC -w
DFLAGS             += -D_REENTRANT -DPIC $(patsubst %,-D%,$(filter BIT_%,$(MAKEFLAGS))) -DBIT_COMP_APPWEB=$(BIT_COMP_APPWEB) -DBIT_COMP_CGI=$(BIT_COMP_CGI) -DBIT_COMP_DIR=$(BIT_COMP_DIR) -DBIT_COMP_EJS=$(BIT_COMP_EJS) -DBIT_COMP_EST=$(BIT_COMP_EST) -DBIT_COMP_LIBEST=$(BIT_COMP_LIBEST) -DBIT_COMP_MATRIXSSL=$(BIT_COMP_MATRIXSSL) -DBIT_COMP_NANOSSL=$(BIT_COMP_NANOSSL) -DBIT_COMP_OPENSSL=$(BIT_COMP_OPENSSL) -DBIT_COMP_PCRE=$(BIT_COMP_PCRE) -DBIT_COMP_PHP=$(BIT_COMP_PHP) -DBIT_COMP_SQLITE=$(BIT_COMP_SQLITE) -DBIT_COMP_SSL=$(BIT_COMP_SSL) -DBIT_COMP_ZLIB=$(BIT_COMP_ZLIB) 
IFLAGS             += "-I$(CONFIG)/inc"
LDFLAGS            += '-rdynamic' '-Wl,--enable-new-dtags' '-Wl,-rpath,$$ORIGIN/'
LIBPATHS           += -L$(CONFIG)/bin
LIBS               += -lrt -ldl -lpthread -lm

DEBUG              := debug
CFLAGS-debug       := -g
DFLAGS-debug       := -DBIT_DEBUG
LDFLAGS-debug      := -g
DFLAGS-release     := 
CFLAGS-release     := -O2
LDFLAGS-release    := 
CFLAGS             += $(CFLAGS-$(DEBUG))
DFLAGS             += $(DFLAGS-$(DEBUG))
LDFLAGS            += $(LDFLAGS-$(DEBUG))

BIT_ROOT_PREFIX    := 
BIT_BASE_PREFIX    := $(BIT_ROOT_PREFIX)/usr/local
BIT_DATA_PREFIX    := $(BIT_ROOT_PREFIX)/
BIT_STATE_PREFIX   := $(BIT_ROOT_PREFIX)/var
BIT_APP_PREFIX     := $(BIT_BASE_PREFIX)/lib/$(PRODUCT)
BIT_VAPP_PREFIX    := $(BIT_APP_PREFIX)/$(VERSION)
BIT_BIN_PREFIX     := $(BIT_ROOT_PREFIX)/usr/local/bin
BIT_INC_PREFIX     := $(BIT_ROOT_PREFIX)/usr/local/include
BIT_LIB_PREFIX     := $(BIT_ROOT_PREFIX)/usr/local/lib
BIT_MAN_PREFIX     := $(BIT_ROOT_PREFIX)/usr/local/share/man
BIT_SBIN_PREFIX    := $(BIT_ROOT_PREFIX)/usr/local/sbin
BIT_ETC_PREFIX     := $(BIT_ROOT_PREFIX)/etc/$(PRODUCT)
BIT_WEB_PREFIX     := $(BIT_ROOT_PREFIX)/var/www/$(PRODUCT)-default
BIT_LOG_PREFIX     := $(BIT_ROOT_PREFIX)/var/log/$(PRODUCT)
BIT_SPOOL_PREFIX   := $(BIT_ROOT_PREFIX)/var/spool/$(PRODUCT)
BIT_CACHE_PREFIX   := $(BIT_ROOT_PREFIX)/var/spool/$(PRODUCT)/cache
BIT_SRC_PREFIX     := $(BIT_ROOT_PREFIX)$(PRODUCT)-$(VERSION)


ifeq ($(BIT_COMP_APPWEB),1)
TARGETS            += $(CONFIG)/bin/libappweb.so
endif
ifeq ($(BIT_COMP_APPWEB),1)
TARGETS            += $(CONFIG)/bin/appweb
endif
ifeq ($(BIT_COMP_EJS),1)
TARGETS            += $(CONFIG)/bin/libejs.so
endif
ifeq ($(BIT_COMP_EJS),1)
TARGETS            += $(CONFIG)/bin/ejsc
endif
ifeq ($(BIT_COMP_EJS),1)
TARGETS            += $(CONFIG)/bin/ejs.mod
endif
ifeq ($(BIT_COMP_EST),1)
TARGETS            += $(CONFIG)/bin/libest.so
endif
TARGETS            += $(CONFIG)/bin/ca.crt
TARGETS            += $(CONFIG)/bin/http
TARGETS            += $(CONFIG)/bin/libmprssl.so
ifeq ($(BIT_COMP_SQLITE),1)
TARGETS            += $(CONFIG)/bin/libsql.so
endif
ifeq ($(BIT_COMP_SQLITE),1)
TARGETS            += $(CONFIG)/bin/sqlite
endif
TARGETS            += $(CONFIG)/bin/libmod_esp.so
TARGETS            += $(CONFIG)/bin/esp
TARGETS            += $(CONFIG)/bin/esp.conf
TARGETS            += $(CONFIG)/paks
TARGETS            += bower.json

unexport CDPATH

ifndef SHOW
.SILENT:
endif

all build compile: prep $(TARGETS)

.PHONY: prep

prep:
	@echo "      [Info] Use "make SHOW=1" to trace executed commands."
	@if [ "$(CONFIG)" = "" ] ; then echo WARNING: CONFIG not set ; exit 255 ; fi
	@if [ "$(BIT_APP_PREFIX)" = "" ] ; then echo WARNING: BIT_APP_PREFIX not set ; exit 255 ; fi
	@[ ! -x $(CONFIG)/bin ] && mkdir -p $(CONFIG)/bin; true
	@[ ! -x $(CONFIG)/inc ] && mkdir -p $(CONFIG)/inc; true
	@[ ! -x $(CONFIG)/obj ] && mkdir -p $(CONFIG)/obj; true
	@[ ! -f $(CONFIG)/inc/bitos.h ] && cp src/bitos.h $(CONFIG)/inc/bitos.h ; true
	@if ! diff $(CONFIG)/inc/bitos.h src/bitos.h >/dev/null ; then\
		cp src/bitos.h $(CONFIG)/inc/bitos.h  ; \
	fi; true
	@[ ! -f $(CONFIG)/inc/bit.h ] && cp projects/esp-linux-default-bit.h $(CONFIG)/inc/bit.h ; true
	@if ! diff $(CONFIG)/inc/bit.h projects/esp-linux-default-bit.h >/dev/null ; then\
		cp projects/esp-linux-default-bit.h $(CONFIG)/inc/bit.h  ; \
	fi; true
	@if [ -f "$(CONFIG)/.makeflags" ] ; then \
		if [ "$(MAKEFLAGS)" != " ` cat $(CONFIG)/.makeflags`" ] ; then \
			echo "   [Warning] Make flags have changed since the last build: "`cat $(CONFIG)/.makeflags`"" ; \
		fi ; \
	fi
	@echo $(MAKEFLAGS) >$(CONFIG)/.makeflags

clean:
	rm -f "$(CONFIG)/bin/libappweb.so"
	rm -f "$(CONFIG)/bin/appweb"
	rm -f "$(CONFIG)/bin/libejs.so"
	rm -f "$(CONFIG)/bin/ejsc"
	rm -f "$(CONFIG)/bin/libest.so"
	rm -f "$(CONFIG)/bin/ca.crt"
	rm -f "$(CONFIG)/bin/libhttp.so"
	rm -f "$(CONFIG)/bin/http"
	rm -f "$(CONFIG)/bin/libmpr.so"
	rm -f "$(CONFIG)/bin/libmprssl.so"
	rm -f "$(CONFIG)/bin/makerom"
	rm -f "$(CONFIG)/bin/libpcre.so"
	rm -f "$(CONFIG)/bin/libsql.so"
	rm -f "$(CONFIG)/bin/sqlite"
	rm -f "$(CONFIG)/bin/libzlib.so"
	rm -f "$(CONFIG)/bin/libmod_esp.so"
	rm -f "$(CONFIG)/bin/esp"
	rm -f "$(CONFIG)/bin/esp.conf"
	rm -f "bower.json"
	rm -f "$(CONFIG)/obj/appwebLib.o"
	rm -f "$(CONFIG)/obj/appweb.o"
	rm -f "$(CONFIG)/obj/ejsLib.o"
	rm -f "$(CONFIG)/obj/ejsc.o"
	rm -f "$(CONFIG)/obj/estLib.o"
	rm -f "$(CONFIG)/obj/httpLib.o"
	rm -f "$(CONFIG)/obj/http.o"
	rm -f "$(CONFIG)/obj/mprLib.o"
	rm -f "$(CONFIG)/obj/mprSsl.o"
	rm -f "$(CONFIG)/obj/makerom.o"
	rm -f "$(CONFIG)/obj/pcre.o"
	rm -f "$(CONFIG)/obj/sqlite3.o"
	rm -f "$(CONFIG)/obj/sqlite.o"
	rm -f "$(CONFIG)/obj/zlib.o"
	rm -f "$(CONFIG)/obj/edi.o"
	rm -f "$(CONFIG)/obj/espAbbrev.o"
	rm -f "$(CONFIG)/obj/espDeprecated.o"
	rm -f "$(CONFIG)/obj/espFramework.o"
	rm -f "$(CONFIG)/obj/espHandler.o"
	rm -f "$(CONFIG)/obj/espHtml.o"
	rm -f "$(CONFIG)/obj/espTemplate.o"
	rm -f "$(CONFIG)/obj/mdb.o"
	rm -f "$(CONFIG)/obj/sdb.o"
	rm -f "$(CONFIG)/obj/esp.o"

clobber: clean
	rm -fr ./$(CONFIG)



#
#   version
#
version: $(DEPS_1)
	echo 0.9.0

#
#   mpr.h
#
$(CONFIG)/inc/mpr.h: $(DEPS_2)
	@echo '      [Copy] $(CONFIG)/inc/mpr.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/paks/mpr/mpr.h $(CONFIG)/inc/mpr.h

#
#   bit.h
#
$(CONFIG)/inc/bit.h: $(DEPS_3)
	@echo '      [Copy] $(CONFIG)/inc/bit.h'

#
#   bitos.h
#
$(CONFIG)/inc/bitos.h: $(DEPS_4)
	@echo '      [Copy] $(CONFIG)/inc/bitos.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/bitos.h $(CONFIG)/inc/bitos.h

#
#   mprLib.o
#
DEPS_5 += $(CONFIG)/inc/bit.h
DEPS_5 += $(CONFIG)/inc/mpr.h
DEPS_5 += $(CONFIG)/inc/bitos.h

$(CONFIG)/obj/mprLib.o: \
    src/paks/mpr/mprLib.c $(DEPS_5)
	@echo '   [Compile] $(CONFIG)/obj/mprLib.o'
	$(CC) -c -o $(CONFIG)/obj/mprLib.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/paks/mpr/mprLib.c

#
#   libmpr
#
DEPS_6 += $(CONFIG)/inc/mpr.h
DEPS_6 += $(CONFIG)/inc/bit.h
DEPS_6 += $(CONFIG)/inc/bitos.h
DEPS_6 += $(CONFIG)/obj/mprLib.o

$(CONFIG)/bin/libmpr.so: $(DEPS_6)
	@echo '      [Link] $(CONFIG)/bin/libmpr.so'
	$(CC) -shared -o $(CONFIG)/bin/libmpr.so $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/mprLib.o" $(LIBS) 

#
#   pcre.h
#
$(CONFIG)/inc/pcre.h: $(DEPS_7)
	@echo '      [Copy] $(CONFIG)/inc/pcre.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/paks/pcre/pcre.h $(CONFIG)/inc/pcre.h

#
#   pcre.o
#
DEPS_8 += $(CONFIG)/inc/bit.h
DEPS_8 += $(CONFIG)/inc/pcre.h

$(CONFIG)/obj/pcre.o: \
    src/paks/pcre/pcre.c $(DEPS_8)
	@echo '   [Compile] $(CONFIG)/obj/pcre.o'
	$(CC) -c -o $(CONFIG)/obj/pcre.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/paks/pcre/pcre.c

ifeq ($(BIT_COMP_PCRE),1)
#
#   libpcre
#
DEPS_9 += $(CONFIG)/inc/pcre.h
DEPS_9 += $(CONFIG)/inc/bit.h
DEPS_9 += $(CONFIG)/obj/pcre.o

$(CONFIG)/bin/libpcre.so: $(DEPS_9)
	@echo '      [Link] $(CONFIG)/bin/libpcre.so'
	$(CC) -shared -o $(CONFIG)/bin/libpcre.so $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/pcre.o" $(LIBS) 
endif

#
#   http.h
#
$(CONFIG)/inc/http.h: $(DEPS_10)
	@echo '      [Copy] $(CONFIG)/inc/http.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/paks/http/http.h $(CONFIG)/inc/http.h

#
#   httpLib.o
#
DEPS_11 += $(CONFIG)/inc/bit.h
DEPS_11 += $(CONFIG)/inc/http.h
DEPS_11 += $(CONFIG)/inc/mpr.h

$(CONFIG)/obj/httpLib.o: \
    src/paks/http/httpLib.c $(DEPS_11)
	@echo '   [Compile] $(CONFIG)/obj/httpLib.o'
	$(CC) -c -o $(CONFIG)/obj/httpLib.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/paks/http/httpLib.c

#
#   libhttp
#
DEPS_12 += $(CONFIG)/inc/mpr.h
DEPS_12 += $(CONFIG)/inc/bit.h
DEPS_12 += $(CONFIG)/inc/bitos.h
DEPS_12 += $(CONFIG)/obj/mprLib.o
DEPS_12 += $(CONFIG)/bin/libmpr.so
DEPS_12 += $(CONFIG)/inc/pcre.h
DEPS_12 += $(CONFIG)/obj/pcre.o
ifeq ($(BIT_COMP_PCRE),1)
    DEPS_12 += $(CONFIG)/bin/libpcre.so
endif
DEPS_12 += $(CONFIG)/inc/http.h
DEPS_12 += $(CONFIG)/obj/httpLib.o

LIBS_12 += -lmpr
ifeq ($(BIT_COMP_PCRE),1)
    LIBS_12 += -lpcre
endif

$(CONFIG)/bin/libhttp.so: $(DEPS_12)
	@echo '      [Link] $(CONFIG)/bin/libhttp.so'
	$(CC) -shared -o $(CONFIG)/bin/libhttp.so $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/httpLib.o" $(LIBPATHS_12) $(LIBS_12) $(LIBS_12) $(LIBS) 

#
#   appweb.h
#
$(CONFIG)/inc/appweb.h: $(DEPS_13)
	@echo '      [Copy] $(CONFIG)/inc/appweb.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/paks/appweb/appweb.h $(CONFIG)/inc/appweb.h

#
#   appwebLib.o
#
DEPS_14 += $(CONFIG)/inc/bit.h
DEPS_14 += $(CONFIG)/inc/appweb.h
DEPS_14 += $(CONFIG)/inc/pcre.h
DEPS_14 += $(CONFIG)/inc/mpr.h
DEPS_14 += $(CONFIG)/inc/http.h

$(CONFIG)/obj/appwebLib.o: \
    src/paks/appweb/appwebLib.c $(DEPS_14)
	@echo '   [Compile] $(CONFIG)/obj/appwebLib.o'
	$(CC) -c -o $(CONFIG)/obj/appwebLib.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/paks/appweb/appwebLib.c

ifeq ($(BIT_COMP_APPWEB),1)
#
#   libappweb
#
DEPS_15 += $(CONFIG)/inc/mpr.h
DEPS_15 += $(CONFIG)/inc/bit.h
DEPS_15 += $(CONFIG)/inc/bitos.h
DEPS_15 += $(CONFIG)/obj/mprLib.o
DEPS_15 += $(CONFIG)/bin/libmpr.so
DEPS_15 += $(CONFIG)/inc/pcre.h
DEPS_15 += $(CONFIG)/obj/pcre.o
ifeq ($(BIT_COMP_PCRE),1)
    DEPS_15 += $(CONFIG)/bin/libpcre.so
endif
DEPS_15 += $(CONFIG)/inc/http.h
DEPS_15 += $(CONFIG)/obj/httpLib.o
DEPS_15 += $(CONFIG)/bin/libhttp.so
DEPS_15 += $(CONFIG)/inc/appweb.h
DEPS_15 += $(CONFIG)/obj/appwebLib.o

LIBS_15 += -lhttp
LIBS_15 += -lmpr
ifeq ($(BIT_COMP_PCRE),1)
    LIBS_15 += -lpcre
endif

$(CONFIG)/bin/libappweb.so: $(DEPS_15)
	@echo '      [Link] $(CONFIG)/bin/libappweb.so'
	$(CC) -shared -o $(CONFIG)/bin/libappweb.so $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/appwebLib.o" $(LIBPATHS_15) $(LIBS_15) $(LIBS_15) $(LIBS) 
endif

#
#   esp.h
#
$(CONFIG)/inc/esp.h: $(DEPS_16)
	@echo '      [Copy] $(CONFIG)/inc/esp.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/esp.h $(CONFIG)/inc/esp.h

#
#   appweb.o
#
DEPS_17 += $(CONFIG)/inc/bit.h
DEPS_17 += $(CONFIG)/inc/appweb.h
DEPS_17 += $(CONFIG)/inc/esp.h

$(CONFIG)/obj/appweb.o: \
    src/paks/appweb/appweb.c $(DEPS_17)
	@echo '   [Compile] $(CONFIG)/obj/appweb.o'
	$(CC) -c -o $(CONFIG)/obj/appweb.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/paks/appweb/appweb.c

ifeq ($(BIT_COMP_APPWEB),1)
#
#   appweb
#
DEPS_18 += $(CONFIG)/inc/mpr.h
DEPS_18 += $(CONFIG)/inc/bit.h
DEPS_18 += $(CONFIG)/inc/bitos.h
DEPS_18 += $(CONFIG)/obj/mprLib.o
DEPS_18 += $(CONFIG)/bin/libmpr.so
DEPS_18 += $(CONFIG)/inc/pcre.h
DEPS_18 += $(CONFIG)/obj/pcre.o
ifeq ($(BIT_COMP_PCRE),1)
    DEPS_18 += $(CONFIG)/bin/libpcre.so
endif
DEPS_18 += $(CONFIG)/inc/http.h
DEPS_18 += $(CONFIG)/obj/httpLib.o
DEPS_18 += $(CONFIG)/bin/libhttp.so
DEPS_18 += $(CONFIG)/inc/appweb.h
DEPS_18 += $(CONFIG)/obj/appwebLib.o
DEPS_18 += $(CONFIG)/bin/libappweb.so
DEPS_18 += $(CONFIG)/inc/esp.h
DEPS_18 += $(CONFIG)/obj/appweb.o

LIBS_18 += -lappweb
LIBS_18 += -lhttp
LIBS_18 += -lmpr
ifeq ($(BIT_COMP_PCRE),1)
    LIBS_18 += -lpcre
endif

$(CONFIG)/bin/appweb: $(DEPS_18)
	@echo '      [Link] $(CONFIG)/bin/appweb'
	$(CC) -o $(CONFIG)/bin/appweb $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/appweb.o" $(LIBPATHS_18) $(LIBS_18) $(LIBS_18) $(LIBS) $(LIBS) 
endif

#
#   zlib.h
#
$(CONFIG)/inc/zlib.h: $(DEPS_19)
	@echo '      [Copy] $(CONFIG)/inc/zlib.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/paks/zlib/zlib.h $(CONFIG)/inc/zlib.h

#
#   zlib.o
#
DEPS_20 += $(CONFIG)/inc/bit.h
DEPS_20 += $(CONFIG)/inc/zlib.h
DEPS_20 += $(CONFIG)/inc/bitos.h

$(CONFIG)/obj/zlib.o: \
    src/paks/zlib/zlib.c $(DEPS_20)
	@echo '   [Compile] $(CONFIG)/obj/zlib.o'
	$(CC) -c -o $(CONFIG)/obj/zlib.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/paks/zlib/zlib.c

ifeq ($(BIT_COMP_ZLIB),1)
#
#   libzlib
#
DEPS_21 += $(CONFIG)/inc/zlib.h
DEPS_21 += $(CONFIG)/inc/bit.h
DEPS_21 += $(CONFIG)/inc/bitos.h
DEPS_21 += $(CONFIG)/obj/zlib.o

$(CONFIG)/bin/libzlib.so: $(DEPS_21)
	@echo '      [Link] $(CONFIG)/bin/libzlib.so'
	$(CC) -shared -o $(CONFIG)/bin/libzlib.so $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/zlib.o" $(LIBS) 
endif

#
#   ejs.h
#
$(CONFIG)/inc/ejs.h: $(DEPS_22)
	@echo '      [Copy] $(CONFIG)/inc/ejs.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/paks/ejs/ejs.h $(CONFIG)/inc/ejs.h

#
#   ejs.slots.h
#
$(CONFIG)/inc/ejs.slots.h: $(DEPS_23)
	@echo '      [Copy] $(CONFIG)/inc/ejs.slots.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/paks/ejs/ejs.slots.h $(CONFIG)/inc/ejs.slots.h

#
#   ejsByteGoto.h
#
$(CONFIG)/inc/ejsByteGoto.h: $(DEPS_24)
	@echo '      [Copy] $(CONFIG)/inc/ejsByteGoto.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/paks/ejs/ejsByteGoto.h $(CONFIG)/inc/ejsByteGoto.h

#
#   ejsLib.o
#
DEPS_25 += $(CONFIG)/inc/bit.h
DEPS_25 += $(CONFIG)/inc/ejs.h
DEPS_25 += $(CONFIG)/inc/mpr.h
DEPS_25 += $(CONFIG)/inc/pcre.h
DEPS_25 += $(CONFIG)/inc/bitos.h
DEPS_25 += $(CONFIG)/inc/http.h
DEPS_25 += $(CONFIG)/inc/ejs.slots.h
DEPS_25 += $(CONFIG)/inc/zlib.h

$(CONFIG)/obj/ejsLib.o: \
    src/paks/ejs/ejsLib.c $(DEPS_25)
	@echo '   [Compile] $(CONFIG)/obj/ejsLib.o'
	$(CC) -c -o $(CONFIG)/obj/ejsLib.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/paks/ejs/ejsLib.c

ifeq ($(BIT_COMP_EJS),1)
#
#   libejs
#
DEPS_26 += $(CONFIG)/inc/mpr.h
DEPS_26 += $(CONFIG)/inc/bit.h
DEPS_26 += $(CONFIG)/inc/bitos.h
DEPS_26 += $(CONFIG)/obj/mprLib.o
DEPS_26 += $(CONFIG)/bin/libmpr.so
DEPS_26 += $(CONFIG)/inc/pcre.h
DEPS_26 += $(CONFIG)/obj/pcre.o
ifeq ($(BIT_COMP_PCRE),1)
    DEPS_26 += $(CONFIG)/bin/libpcre.so
endif
DEPS_26 += $(CONFIG)/inc/http.h
DEPS_26 += $(CONFIG)/obj/httpLib.o
DEPS_26 += $(CONFIG)/bin/libhttp.so
DEPS_26 += $(CONFIG)/inc/zlib.h
DEPS_26 += $(CONFIG)/obj/zlib.o
ifeq ($(BIT_COMP_ZLIB),1)
    DEPS_26 += $(CONFIG)/bin/libzlib.so
endif
DEPS_26 += $(CONFIG)/inc/ejs.h
DEPS_26 += $(CONFIG)/inc/ejs.slots.h
DEPS_26 += $(CONFIG)/inc/ejsByteGoto.h
DEPS_26 += $(CONFIG)/obj/ejsLib.o

LIBS_26 += -lhttp
LIBS_26 += -lmpr
ifeq ($(BIT_COMP_PCRE),1)
    LIBS_26 += -lpcre
endif
ifeq ($(BIT_COMP_ZLIB),1)
    LIBS_26 += -lzlib
endif

$(CONFIG)/bin/libejs.so: $(DEPS_26)
	@echo '      [Link] $(CONFIG)/bin/libejs.so'
	$(CC) -shared -o $(CONFIG)/bin/libejs.so $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/ejsLib.o" $(LIBPATHS_26) $(LIBS_26) $(LIBS_26) $(LIBS) 
endif

#
#   ejsc.o
#
DEPS_27 += $(CONFIG)/inc/bit.h
DEPS_27 += $(CONFIG)/inc/ejs.h

$(CONFIG)/obj/ejsc.o: \
    src/paks/ejs/ejsc.c $(DEPS_27)
	@echo '   [Compile] $(CONFIG)/obj/ejsc.o'
	$(CC) -c -o $(CONFIG)/obj/ejsc.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/paks/ejs/ejsc.c

ifeq ($(BIT_COMP_EJS),1)
#
#   ejsc
#
DEPS_28 += $(CONFIG)/inc/mpr.h
DEPS_28 += $(CONFIG)/inc/bit.h
DEPS_28 += $(CONFIG)/inc/bitos.h
DEPS_28 += $(CONFIG)/obj/mprLib.o
DEPS_28 += $(CONFIG)/bin/libmpr.so
DEPS_28 += $(CONFIG)/inc/pcre.h
DEPS_28 += $(CONFIG)/obj/pcre.o
ifeq ($(BIT_COMP_PCRE),1)
    DEPS_28 += $(CONFIG)/bin/libpcre.so
endif
DEPS_28 += $(CONFIG)/inc/http.h
DEPS_28 += $(CONFIG)/obj/httpLib.o
DEPS_28 += $(CONFIG)/bin/libhttp.so
DEPS_28 += $(CONFIG)/inc/zlib.h
DEPS_28 += $(CONFIG)/obj/zlib.o
ifeq ($(BIT_COMP_ZLIB),1)
    DEPS_28 += $(CONFIG)/bin/libzlib.so
endif
DEPS_28 += $(CONFIG)/inc/ejs.h
DEPS_28 += $(CONFIG)/inc/ejs.slots.h
DEPS_28 += $(CONFIG)/inc/ejsByteGoto.h
DEPS_28 += $(CONFIG)/obj/ejsLib.o
DEPS_28 += $(CONFIG)/bin/libejs.so
DEPS_28 += $(CONFIG)/obj/ejsc.o

LIBS_28 += -lejs
LIBS_28 += -lhttp
LIBS_28 += -lmpr
ifeq ($(BIT_COMP_PCRE),1)
    LIBS_28 += -lpcre
endif
ifeq ($(BIT_COMP_ZLIB),1)
    LIBS_28 += -lzlib
endif

$(CONFIG)/bin/ejsc: $(DEPS_28)
	@echo '      [Link] $(CONFIG)/bin/ejsc'
	$(CC) -o $(CONFIG)/bin/ejsc $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/ejsc.o" $(LIBPATHS_28) $(LIBS_28) $(LIBS_28) $(LIBS) $(LIBS) 
endif

ifeq ($(BIT_COMP_EJS),1)
#
#   ejs.mod
#
DEPS_29 += src/paks/ejs/ejs.es
DEPS_29 += $(CONFIG)/inc/mpr.h
DEPS_29 += $(CONFIG)/inc/bit.h
DEPS_29 += $(CONFIG)/inc/bitos.h
DEPS_29 += $(CONFIG)/obj/mprLib.o
DEPS_29 += $(CONFIG)/bin/libmpr.so
DEPS_29 += $(CONFIG)/inc/pcre.h
DEPS_29 += $(CONFIG)/obj/pcre.o
ifeq ($(BIT_COMP_PCRE),1)
    DEPS_29 += $(CONFIG)/bin/libpcre.so
endif
DEPS_29 += $(CONFIG)/inc/http.h
DEPS_29 += $(CONFIG)/obj/httpLib.o
DEPS_29 += $(CONFIG)/bin/libhttp.so
DEPS_29 += $(CONFIG)/inc/zlib.h
DEPS_29 += $(CONFIG)/obj/zlib.o
ifeq ($(BIT_COMP_ZLIB),1)
    DEPS_29 += $(CONFIG)/bin/libzlib.so
endif
DEPS_29 += $(CONFIG)/inc/ejs.h
DEPS_29 += $(CONFIG)/inc/ejs.slots.h
DEPS_29 += $(CONFIG)/inc/ejsByteGoto.h
DEPS_29 += $(CONFIG)/obj/ejsLib.o
DEPS_29 += $(CONFIG)/bin/libejs.so
DEPS_29 += $(CONFIG)/obj/ejsc.o
DEPS_29 += $(CONFIG)/bin/ejsc

$(CONFIG)/bin/ejs.mod: $(DEPS_29)
	( \
	cd src/paks/ejs; \
	../../../$(CONFIG)/bin/ejsc --out ../../../$(CONFIG)/bin/ejs.mod --optimize 9 --bind --require null ejs.es ; \
	)
endif

#
#   est.h
#
$(CONFIG)/inc/est.h: $(DEPS_30)
	@echo '      [Copy] $(CONFIG)/inc/est.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/paks/est/est.h $(CONFIG)/inc/est.h

#
#   estLib.o
#
DEPS_31 += $(CONFIG)/inc/bit.h
DEPS_31 += $(CONFIG)/inc/est.h
DEPS_31 += $(CONFIG)/inc/bitos.h

$(CONFIG)/obj/estLib.o: \
    src/paks/est/estLib.c $(DEPS_31)
	@echo '   [Compile] $(CONFIG)/obj/estLib.o'
	$(CC) -c -o $(CONFIG)/obj/estLib.o -fPIC $(DFLAGS) $(IFLAGS) src/paks/est/estLib.c

ifeq ($(BIT_COMP_EST),1)
#
#   libest
#
DEPS_32 += $(CONFIG)/inc/est.h
DEPS_32 += $(CONFIG)/inc/bit.h
DEPS_32 += $(CONFIG)/inc/bitos.h
DEPS_32 += $(CONFIG)/obj/estLib.o

$(CONFIG)/bin/libest.so: $(DEPS_32)
	@echo '      [Link] $(CONFIG)/bin/libest.so'
	$(CC) -shared -o $(CONFIG)/bin/libest.so $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/estLib.o" $(LIBS) 
endif

#
#   ca-crt
#
DEPS_33 += src/paks/est/ca.crt

$(CONFIG)/bin/ca.crt: $(DEPS_33)
	@echo '      [Copy] $(CONFIG)/bin/ca.crt'
	mkdir -p "$(CONFIG)/bin"
	cp src/paks/est/ca.crt $(CONFIG)/bin/ca.crt

#
#   http.o
#
DEPS_34 += $(CONFIG)/inc/bit.h
DEPS_34 += $(CONFIG)/inc/http.h

$(CONFIG)/obj/http.o: \
    src/paks/http/http.c $(DEPS_34)
	@echo '   [Compile] $(CONFIG)/obj/http.o'
	$(CC) -c -o $(CONFIG)/obj/http.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/paks/http/http.c

#
#   http
#
DEPS_35 += $(CONFIG)/inc/mpr.h
DEPS_35 += $(CONFIG)/inc/bit.h
DEPS_35 += $(CONFIG)/inc/bitos.h
DEPS_35 += $(CONFIG)/obj/mprLib.o
DEPS_35 += $(CONFIG)/bin/libmpr.so
DEPS_35 += $(CONFIG)/inc/pcre.h
DEPS_35 += $(CONFIG)/obj/pcre.o
ifeq ($(BIT_COMP_PCRE),1)
    DEPS_35 += $(CONFIG)/bin/libpcre.so
endif
DEPS_35 += $(CONFIG)/inc/http.h
DEPS_35 += $(CONFIG)/obj/httpLib.o
DEPS_35 += $(CONFIG)/bin/libhttp.so
DEPS_35 += $(CONFIG)/obj/http.o

LIBS_35 += -lhttp
LIBS_35 += -lmpr
ifeq ($(BIT_COMP_PCRE),1)
    LIBS_35 += -lpcre
endif

$(CONFIG)/bin/http: $(DEPS_35)
	@echo '      [Link] $(CONFIG)/bin/http'
	$(CC) -o $(CONFIG)/bin/http $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/http.o" $(LIBPATHS_35) $(LIBS_35) $(LIBS_35) $(LIBS) $(LIBS) 

#
#   mprSsl.o
#
DEPS_36 += $(CONFIG)/inc/bit.h
DEPS_36 += $(CONFIG)/inc/mpr.h
DEPS_36 += $(CONFIG)/inc/est.h

$(CONFIG)/obj/mprSsl.o: \
    src/paks/mpr/mprSsl.c $(DEPS_36)
	@echo '   [Compile] $(CONFIG)/obj/mprSsl.o'
	$(CC) -c -o $(CONFIG)/obj/mprSsl.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/paks/mpr/mprSsl.c

#
#   libmprssl
#
DEPS_37 += $(CONFIG)/inc/mpr.h
DEPS_37 += $(CONFIG)/inc/bit.h
DEPS_37 += $(CONFIG)/inc/bitos.h
DEPS_37 += $(CONFIG)/obj/mprLib.o
DEPS_37 += $(CONFIG)/bin/libmpr.so
DEPS_37 += $(CONFIG)/inc/est.h
DEPS_37 += $(CONFIG)/obj/estLib.o
ifeq ($(BIT_COMP_EST),1)
    DEPS_37 += $(CONFIG)/bin/libest.so
endif
DEPS_37 += $(CONFIG)/obj/mprSsl.o

LIBS_37 += -lmpr
ifeq ($(BIT_COMP_EST),1)
    LIBS_37 += -lest
endif

$(CONFIG)/bin/libmprssl.so: $(DEPS_37)
	@echo '      [Link] $(CONFIG)/bin/libmprssl.so'
	$(CC) -shared -o $(CONFIG)/bin/libmprssl.so $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/mprSsl.o" $(LIBPATHS_37) $(LIBS_37) $(LIBS_37) $(LIBS) 

#
#   sqlite3.h
#
$(CONFIG)/inc/sqlite3.h: $(DEPS_38)
	@echo '      [Copy] $(CONFIG)/inc/sqlite3.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/paks/sqlite/sqlite3.h $(CONFIG)/inc/sqlite3.h

#
#   sqlite3.o
#
DEPS_39 += $(CONFIG)/inc/bit.h
DEPS_39 += $(CONFIG)/inc/sqlite3.h

$(CONFIG)/obj/sqlite3.o: \
    src/paks/sqlite/sqlite3.c $(DEPS_39)
	@echo '   [Compile] $(CONFIG)/obj/sqlite3.o'
	$(CC) -c -o $(CONFIG)/obj/sqlite3.o -fPIC $(DFLAGS) $(IFLAGS) src/paks/sqlite/sqlite3.c

ifeq ($(BIT_COMP_SQLITE),1)
#
#   libsql
#
DEPS_40 += $(CONFIG)/inc/sqlite3.h
DEPS_40 += $(CONFIG)/inc/bit.h
DEPS_40 += $(CONFIG)/obj/sqlite3.o

$(CONFIG)/bin/libsql.so: $(DEPS_40)
	@echo '      [Link] $(CONFIG)/bin/libsql.so'
	$(CC) -shared -o $(CONFIG)/bin/libsql.so $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/sqlite3.o" $(LIBS) 
endif

#
#   sqlite.o
#
DEPS_41 += $(CONFIG)/inc/bit.h
DEPS_41 += $(CONFIG)/inc/sqlite3.h

$(CONFIG)/obj/sqlite.o: \
    src/paks/sqlite/sqlite.c $(DEPS_41)
	@echo '   [Compile] $(CONFIG)/obj/sqlite.o'
	$(CC) -c -o $(CONFIG)/obj/sqlite.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/paks/sqlite/sqlite.c

ifeq ($(BIT_COMP_SQLITE),1)
#
#   sqliteshell
#
DEPS_42 += $(CONFIG)/inc/sqlite3.h
DEPS_42 += $(CONFIG)/inc/bit.h
DEPS_42 += $(CONFIG)/obj/sqlite3.o
DEPS_42 += $(CONFIG)/bin/libsql.so
DEPS_42 += $(CONFIG)/obj/sqlite.o

LIBS_42 += -lsql

$(CONFIG)/bin/sqlite: $(DEPS_42)
	@echo '      [Link] $(CONFIG)/bin/sqlite'
	$(CC) -o $(CONFIG)/bin/sqlite $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/sqlite.o" $(LIBPATHS_42) $(LIBS_42) $(LIBS_42) $(LIBS) $(LIBS) 
endif

#
#   edi.h
#
$(CONFIG)/inc/edi.h: $(DEPS_43)
	@echo '      [Copy] $(CONFIG)/inc/edi.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/edi.h $(CONFIG)/inc/edi.h

#
#   mdb.h
#
$(CONFIG)/inc/mdb.h: $(DEPS_44)
	@echo '      [Copy] $(CONFIG)/inc/mdb.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/mdb.h $(CONFIG)/inc/mdb.h

#
#   edi.o
#
DEPS_45 += $(CONFIG)/inc/bit.h
DEPS_45 += $(CONFIG)/inc/edi.h
DEPS_45 += $(CONFIG)/inc/pcre.h

$(CONFIG)/obj/edi.o: \
    src/edi.c $(DEPS_45)
	@echo '   [Compile] $(CONFIG)/obj/edi.o'
	$(CC) -c -o $(CONFIG)/obj/edi.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/edi.c

#
#   espAbbrev.o
#
DEPS_46 += $(CONFIG)/inc/bit.h
DEPS_46 += $(CONFIG)/inc/esp.h

$(CONFIG)/obj/espAbbrev.o: \
    src/espAbbrev.c $(DEPS_46)
	@echo '   [Compile] $(CONFIG)/obj/espAbbrev.o'
	$(CC) -c -o $(CONFIG)/obj/espAbbrev.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/espAbbrev.c

#
#   espDeprecated.o
#
DEPS_47 += $(CONFIG)/inc/bit.h
DEPS_47 += $(CONFIG)/inc/esp.h
DEPS_47 += $(CONFIG)/inc/edi.h

$(CONFIG)/obj/espDeprecated.o: \
    src/espDeprecated.c $(DEPS_47)
	@echo '   [Compile] $(CONFIG)/obj/espDeprecated.o'
	$(CC) -c -o $(CONFIG)/obj/espDeprecated.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/espDeprecated.c

#
#   espFramework.o
#
DEPS_48 += $(CONFIG)/inc/bit.h
DEPS_48 += $(CONFIG)/inc/esp.h

$(CONFIG)/obj/espFramework.o: \
    src/espFramework.c $(DEPS_48)
	@echo '   [Compile] $(CONFIG)/obj/espFramework.o'
	$(CC) -c -o $(CONFIG)/obj/espFramework.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/espFramework.c

#
#   espHandler.o
#
DEPS_49 += $(CONFIG)/inc/bit.h
DEPS_49 += $(CONFIG)/inc/http.h
DEPS_49 += $(CONFIG)/inc/esp.h
DEPS_49 += $(CONFIG)/inc/edi.h

$(CONFIG)/obj/espHandler.o: \
    src/espHandler.c $(DEPS_49)
	@echo '   [Compile] $(CONFIG)/obj/espHandler.o'
	$(CC) -c -o $(CONFIG)/obj/espHandler.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/espHandler.c

#
#   espHtml.o
#
DEPS_50 += $(CONFIG)/inc/bit.h
DEPS_50 += $(CONFIG)/inc/esp.h
DEPS_50 += $(CONFIG)/inc/edi.h

$(CONFIG)/obj/espHtml.o: \
    src/espHtml.c $(DEPS_50)
	@echo '   [Compile] $(CONFIG)/obj/espHtml.o'
	$(CC) -c -o $(CONFIG)/obj/espHtml.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/espHtml.c

#
#   espTemplate.o
#
DEPS_51 += $(CONFIG)/inc/bit.h
DEPS_51 += $(CONFIG)/inc/esp.h

$(CONFIG)/obj/espTemplate.o: \
    src/espTemplate.c $(DEPS_51)
	@echo '   [Compile] $(CONFIG)/obj/espTemplate.o'
	$(CC) -c -o $(CONFIG)/obj/espTemplate.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/espTemplate.c

#
#   mdb.o
#
DEPS_52 += $(CONFIG)/inc/bit.h
DEPS_52 += $(CONFIG)/inc/http.h
DEPS_52 += $(CONFIG)/inc/edi.h
DEPS_52 += $(CONFIG)/inc/mdb.h
DEPS_52 += $(CONFIG)/inc/pcre.h

$(CONFIG)/obj/mdb.o: \
    src/mdb.c $(DEPS_52)
	@echo '   [Compile] $(CONFIG)/obj/mdb.o'
	$(CC) -c -o $(CONFIG)/obj/mdb.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/mdb.c

#
#   sdb.o
#
DEPS_53 += $(CONFIG)/inc/bit.h
DEPS_53 += $(CONFIG)/inc/http.h

$(CONFIG)/obj/sdb.o: \
    src/sdb.c $(DEPS_53)
	@echo '   [Compile] $(CONFIG)/obj/sdb.o'
	$(CC) -c -o $(CONFIG)/obj/sdb.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/sdb.c

#
#   libmod_esp
#
DEPS_54 += $(CONFIG)/inc/mpr.h
DEPS_54 += $(CONFIG)/inc/bit.h
DEPS_54 += $(CONFIG)/inc/bitos.h
DEPS_54 += $(CONFIG)/obj/mprLib.o
DEPS_54 += $(CONFIG)/bin/libmpr.so
DEPS_54 += $(CONFIG)/inc/pcre.h
DEPS_54 += $(CONFIG)/obj/pcre.o
ifeq ($(BIT_COMP_PCRE),1)
    DEPS_54 += $(CONFIG)/bin/libpcre.so
endif
DEPS_54 += $(CONFIG)/inc/http.h
DEPS_54 += $(CONFIG)/obj/httpLib.o
DEPS_54 += $(CONFIG)/bin/libhttp.so
DEPS_54 += $(CONFIG)/inc/appweb.h
DEPS_54 += $(CONFIG)/obj/appwebLib.o
ifeq ($(BIT_COMP_APPWEB),1)
    DEPS_54 += $(CONFIG)/bin/libappweb.so
endif
DEPS_54 += $(CONFIG)/inc/edi.h
DEPS_54 += $(CONFIG)/inc/esp.h
DEPS_54 += $(CONFIG)/inc/mdb.h
DEPS_54 += $(CONFIG)/obj/edi.o
DEPS_54 += $(CONFIG)/obj/espAbbrev.o
DEPS_54 += $(CONFIG)/obj/espDeprecated.o
DEPS_54 += $(CONFIG)/obj/espFramework.o
DEPS_54 += $(CONFIG)/obj/espHandler.o
DEPS_54 += $(CONFIG)/obj/espHtml.o
DEPS_54 += $(CONFIG)/obj/espTemplate.o
DEPS_54 += $(CONFIG)/obj/mdb.o
DEPS_54 += $(CONFIG)/obj/sdb.o

ifeq ($(BIT_COMP_APPWEB),1)
    LIBS_54 += -lappweb
endif
LIBS_54 += -lhttp
LIBS_54 += -lmpr
ifeq ($(BIT_COMP_PCRE),1)
    LIBS_54 += -lpcre
endif
ifeq ($(BIT_COMP_SQLITE),1)
    LIBS_54 += -lsql
endif

$(CONFIG)/bin/libmod_esp.so: $(DEPS_54)
	@echo '      [Link] $(CONFIG)/bin/libmod_esp.so'
	$(CC) -shared -o $(CONFIG)/bin/libmod_esp.so $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/edi.o" "$(CONFIG)/obj/espAbbrev.o" "$(CONFIG)/obj/espDeprecated.o" "$(CONFIG)/obj/espFramework.o" "$(CONFIG)/obj/espHandler.o" "$(CONFIG)/obj/espHtml.o" "$(CONFIG)/obj/espTemplate.o" "$(CONFIG)/obj/mdb.o" "$(CONFIG)/obj/sdb.o" $(LIBPATHS_54) $(LIBS_54) $(LIBS_54) $(LIBS) 

#
#   esp.o
#
DEPS_55 += $(CONFIG)/inc/bit.h
DEPS_55 += $(CONFIG)/inc/esp.h

$(CONFIG)/obj/esp.o: \
    src/esp.c $(DEPS_55)
	@echo '   [Compile] $(CONFIG)/obj/esp.o'
	$(CC) -c -o $(CONFIG)/obj/esp.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/esp.c

#
#   espcmd
#
DEPS_56 += $(CONFIG)/inc/mpr.h
DEPS_56 += $(CONFIG)/inc/bit.h
DEPS_56 += $(CONFIG)/inc/bitos.h
DEPS_56 += $(CONFIG)/obj/mprLib.o
DEPS_56 += $(CONFIG)/bin/libmpr.so
DEPS_56 += $(CONFIG)/inc/pcre.h
DEPS_56 += $(CONFIG)/obj/pcre.o
ifeq ($(BIT_COMP_PCRE),1)
    DEPS_56 += $(CONFIG)/bin/libpcre.so
endif
DEPS_56 += $(CONFIG)/inc/http.h
DEPS_56 += $(CONFIG)/obj/httpLib.o
DEPS_56 += $(CONFIG)/bin/libhttp.so
DEPS_56 += $(CONFIG)/inc/appweb.h
DEPS_56 += $(CONFIG)/obj/appwebLib.o
ifeq ($(BIT_COMP_APPWEB),1)
    DEPS_56 += $(CONFIG)/bin/libappweb.so
endif
DEPS_56 += $(CONFIG)/inc/edi.h
DEPS_56 += $(CONFIG)/inc/esp.h
DEPS_56 += $(CONFIG)/inc/mdb.h
DEPS_56 += $(CONFIG)/obj/edi.o
DEPS_56 += $(CONFIG)/obj/espAbbrev.o
DEPS_56 += $(CONFIG)/obj/espDeprecated.o
DEPS_56 += $(CONFIG)/obj/espFramework.o
DEPS_56 += $(CONFIG)/obj/espHandler.o
DEPS_56 += $(CONFIG)/obj/espHtml.o
DEPS_56 += $(CONFIG)/obj/espTemplate.o
DEPS_56 += $(CONFIG)/obj/mdb.o
DEPS_56 += $(CONFIG)/obj/sdb.o
DEPS_56 += $(CONFIG)/bin/libmod_esp.so
DEPS_56 += $(CONFIG)/obj/esp.o

ifeq ($(BIT_COMP_APPWEB),1)
    LIBS_56 += -lappweb
endif
LIBS_56 += -lhttp
LIBS_56 += -lmpr
ifeq ($(BIT_COMP_PCRE),1)
    LIBS_56 += -lpcre
endif
ifeq ($(BIT_COMP_SQLITE),1)
    LIBS_56 += -lsql
endif
LIBS_56 += -lmod_esp

$(CONFIG)/bin/esp: $(DEPS_56)
	@echo '      [Link] $(CONFIG)/bin/esp'
	$(CC) -o $(CONFIG)/bin/esp $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/edi.o" "$(CONFIG)/obj/esp.o" "$(CONFIG)/obj/espAbbrev.o" "$(CONFIG)/obj/espDeprecated.o" "$(CONFIG)/obj/espFramework.o" "$(CONFIG)/obj/espHandler.o" "$(CONFIG)/obj/espHtml.o" "$(CONFIG)/obj/espTemplate.o" "$(CONFIG)/obj/mdb.o" "$(CONFIG)/obj/sdb.o" $(LIBPATHS_56) $(LIBS_56) $(LIBS_56) $(LIBS) $(LIBS) 

#
#   esp.conf
#
DEPS_57 += src/esp.conf

$(CONFIG)/bin/esp.conf: $(DEPS_57)
	@echo '      [Copy] $(CONFIG)/bin/esp.conf'
	mkdir -p "$(CONFIG)/bin"
	cp src/esp.conf $(CONFIG)/bin/esp.conf

#
#   esp-paks
#
DEPS_58 += src/paks/angular
DEPS_58 += src/paks/angular/angular-animate.js
DEPS_58 += src/paks/angular/angular-csp.css
DEPS_58 += src/paks/angular/angular-route.js
DEPS_58 += src/paks/angular/angular.js
DEPS_58 += src/paks/angular/package.json
DEPS_58 += src/paks/appweb
DEPS_58 += src/paks/appweb/appweb.bit
DEPS_58 += src/paks/appweb/appweb.c
DEPS_58 += src/paks/appweb/appweb.h
DEPS_58 += src/paks/appweb/appwebLib.c
DEPS_58 += src/paks/appweb/bower.json
DEPS_58 += src/paks/appweb/LICENSE.md
DEPS_58 += src/paks/appweb/package.json
DEPS_58 += src/paks/appweb/README.md
DEPS_58 += src/paks/bitos
DEPS_58 += src/paks/bitos/bitos.bit
DEPS_58 += src/paks/bitos/bower.json
DEPS_58 += src/paks/bitos/LICENSE.md
DEPS_58 += src/paks/bitos/package.json
DEPS_58 += src/paks/bitos/README.md
DEPS_58 += src/paks/bitos/src
DEPS_58 += src/paks/ejs
DEPS_58 += src/paks/ejs/bower.json
DEPS_58 += src/paks/ejs/ejs.bit
DEPS_58 += src/paks/ejs/ejs.c
DEPS_58 += src/paks/ejs/ejs.es
DEPS_58 += src/paks/ejs/ejs.h
DEPS_58 += src/paks/ejs/ejs.slots.h
DEPS_58 += src/paks/ejs/ejsByteGoto.h
DEPS_58 += src/paks/ejs/ejsc.c
DEPS_58 += src/paks/ejs/ejsLib.c
DEPS_58 += src/paks/ejs/LICENSE.md
DEPS_58 += src/paks/ejs/package.json
DEPS_58 += src/paks/ejs/README.md
DEPS_58 += src/paks/esp-angular
DEPS_58 += src/paks/esp-angular/esp-click.js
DEPS_58 += src/paks/esp-angular/esp-edit.js
DEPS_58 += src/paks/esp-angular/esp-field-errors.js
DEPS_58 += src/paks/esp-angular/esp-fixnum.js
DEPS_58 += src/paks/esp-angular/esp-format.js
DEPS_58 += src/paks/esp-angular/esp-input-group.js
DEPS_58 += src/paks/esp-angular/esp-input.js
DEPS_58 += src/paks/esp-angular/esp-resource.js
DEPS_58 += src/paks/esp-angular/esp-session.js
DEPS_58 += src/paks/esp-angular/esp-titlecase.js
DEPS_58 += src/paks/esp-angular/esp.js
DEPS_58 += src/paks/esp-angular/package.json
DEPS_58 += src/paks/esp-angular-mvc
DEPS_58 += src/paks/esp-angular-mvc/package.json
DEPS_58 += src/paks/esp-html-mvc
DEPS_58 += src/paks/esp-html-mvc/package.json
DEPS_58 += src/paks/esp-legacy-mvc
DEPS_58 += src/paks/esp-legacy-mvc/package.json
DEPS_58 += src/paks/esp-server
DEPS_58 += src/paks/esp-server/package.json
DEPS_58 += src/paks/est
DEPS_58 += src/paks/est/bower.json
DEPS_58 += src/paks/est/ca.crt
DEPS_58 += src/paks/est/est.bit
DEPS_58 += src/paks/est/est.h
DEPS_58 += src/paks/est/estLib.c
DEPS_58 += src/paks/est/LICENSE.md
DEPS_58 += src/paks/est/package.json
DEPS_58 += src/paks/est/README.md
DEPS_58 += src/paks/http
DEPS_58 += src/paks/http/bower.json
DEPS_58 += src/paks/http/http.bit
DEPS_58 += src/paks/http/http.c
DEPS_58 += src/paks/http/http.h
DEPS_58 += src/paks/http/httpLib.c
DEPS_58 += src/paks/http/LICENSE.md
DEPS_58 += src/paks/http/package.json
DEPS_58 += src/paks/http/README.md
DEPS_58 += src/paks/mpr
DEPS_58 += src/paks/mpr/bower.json
DEPS_58 += src/paks/mpr/LICENSE.md
DEPS_58 += src/paks/mpr/makerom.c
DEPS_58 += src/paks/mpr/manager.c
DEPS_58 += src/paks/mpr/mpr.bit
DEPS_58 += src/paks/mpr/mpr.h
DEPS_58 += src/paks/mpr/mprLib.c
DEPS_58 += src/paks/mpr/mprSsl.c
DEPS_58 += src/paks/mpr/package.json
DEPS_58 += src/paks/mpr/README.md
DEPS_58 += src/paks/pcre
DEPS_58 += src/paks/pcre/bower.json
DEPS_58 += src/paks/pcre/LICENSE.md
DEPS_58 += src/paks/pcre/package.json
DEPS_58 += src/paks/pcre/pcre.bit
DEPS_58 += src/paks/pcre/pcre.c
DEPS_58 += src/paks/pcre/pcre.h
DEPS_58 += src/paks/pcre/README.md
DEPS_58 += src/paks/sqlite
DEPS_58 += src/paks/sqlite/bower.json
DEPS_58 += src/paks/sqlite/LICENSE.md
DEPS_58 += src/paks/sqlite/package.json
DEPS_58 += src/paks/sqlite/README.md
DEPS_58 += src/paks/sqlite/sqlite.bit
DEPS_58 += src/paks/sqlite/sqlite.c
DEPS_58 += src/paks/sqlite/sqlite3.c
DEPS_58 += src/paks/sqlite/sqlite3.h
DEPS_58 += src/paks/zlib
DEPS_58 += src/paks/zlib/bower.json
DEPS_58 += src/paks/zlib/LICENSE.md
DEPS_58 += src/paks/zlib/package.json
DEPS_58 += src/paks/zlib/README.md
DEPS_58 += src/paks/zlib/zlib.bit
DEPS_58 += src/paks/zlib/zlib.c
DEPS_58 += src/paks/zlib/zlib.h

$(CONFIG)/paks: $(DEPS_58)
	( \
	cd src/paks; \
	mkdir -p "../../$(CONFIG)/paks/esp-angular/4.5.1" ; \
	cp esp-angular/esp-click.js ../../$(CONFIG)/paks/esp-angular/4.5.1/esp-click.js ; \
	cp esp-angular/esp-edit.js ../../$(CONFIG)/paks/esp-angular/4.5.1/esp-edit.js ; \
	cp esp-angular/esp-field-errors.js ../../$(CONFIG)/paks/esp-angular/4.5.1/esp-field-errors.js ; \
	cp esp-angular/esp-fixnum.js ../../$(CONFIG)/paks/esp-angular/4.5.1/esp-fixnum.js ; \
	cp esp-angular/esp-format.js ../../$(CONFIG)/paks/esp-angular/4.5.1/esp-format.js ; \
	cp esp-angular/esp-input-group.js ../../$(CONFIG)/paks/esp-angular/4.5.1/esp-input-group.js ; \
	cp esp-angular/esp-input.js ../../$(CONFIG)/paks/esp-angular/4.5.1/esp-input.js ; \
	cp esp-angular/esp-resource.js ../../$(CONFIG)/paks/esp-angular/4.5.1/esp-resource.js ; \
	cp esp-angular/esp-session.js ../../$(CONFIG)/paks/esp-angular/4.5.1/esp-session.js ; \
	cp esp-angular/esp-titlecase.js ../../$(CONFIG)/paks/esp-angular/4.5.1/esp-titlecase.js ; \
	cp esp-angular/esp.js ../../$(CONFIG)/paks/esp-angular/4.5.1/esp.js ; \
	cp esp-angular/package.json ../../$(CONFIG)/paks/esp-angular/4.5.1/package.json ; \
	mkdir -p "../../$(CONFIG)/paks/esp-angular-mvc/4.5.1" ; \
	cp esp-angular-mvc/package.json ../../$(CONFIG)/paks/esp-angular-mvc/4.5.1/package.json ; \
	mkdir -p "../../$(CONFIG)/paks/esp-html-mvc/4.5.1" ; \
	cp esp-html-mvc/package.json ../../$(CONFIG)/paks/esp-html-mvc/4.5.1/package.json ; \
	mkdir -p "../../$(CONFIG)/paks/esp-legacy-mvc/4.5.1" ; \
	cp esp-legacy-mvc/package.json ../../$(CONFIG)/paks/esp-legacy-mvc/4.5.1/package.json ; \
	mkdir -p "../../$(CONFIG)/paks/esp-server/4.5.1" ; \
	cp esp-server/package.json ../../$(CONFIG)/paks/esp-server/4.5.1/package.json ; \
	)

#
#   bower.json
#
DEPS_59 += package.json

bower.json: $(DEPS_59)
	@echo '      [Copy] bower.json'
	mkdir -p "."
	cp package.json bower.json

#
#   stop
#
stop: $(DEPS_60)

#
#   installBinary
#
installBinary: $(DEPS_61)
	( \
	cd .; \
	mkdir -p "$(BIT_APP_PREFIX)" ; \
	rm -f "$(BIT_APP_PREFIX)/latest" ; \
	ln -s "0.9.0" "$(BIT_APP_PREFIX)/latest" ; \
	mkdir -p "$(BIT_VAPP_PREFIX)/bin" ; \
	cp $(CONFIG)/bin/pak $(BIT_VAPP_PREFIX)/bin/pak ; \
	mkdir -p "$(BIT_BIN_PREFIX)" ; \
	rm -f "$(BIT_BIN_PREFIX)/pak" ; \
	ln -s "$(BIT_VAPP_PREFIX)/bin/pak" "$(BIT_BIN_PREFIX)/pak" ; \
	cp $(CONFIG)/bin/libejs.so $(BIT_VAPP_PREFIX)/bin/libejs.so ; \
	cp $(CONFIG)/bin/libest.so $(BIT_VAPP_PREFIX)/bin/libest.so ; \
	cp $(CONFIG)/bin/libhttp.so $(BIT_VAPP_PREFIX)/bin/libhttp.so ; \
	cp $(CONFIG)/bin/libmpr.so $(BIT_VAPP_PREFIX)/bin/libmpr.so ; \
	cp $(CONFIG)/bin/libmprssl.so $(BIT_VAPP_PREFIX)/bin/libmprssl.so ; \
	cp $(CONFIG)/bin/libpcre.so $(BIT_VAPP_PREFIX)/bin/libpcre.so ; \
	cp $(CONFIG)/bin/libzlib.so $(BIT_VAPP_PREFIX)/bin/libzlib.so ; \
	cp $(CONFIG)/bin/ca.crt $(BIT_VAPP_PREFIX)/bin/ca.crt ; \
	cp $(CONFIG)/bin/ejs.mod $(BIT_VAPP_PREFIX)/bin/ejs.mod ; \
	cp $(CONFIG)/bin/pak.mod $(BIT_VAPP_PREFIX)/bin/pak.mod ; \
	mkdir -p "$(BIT_VAPP_PREFIX)/doc/man/man1" ; \
	cp doc/man/pak.1 $(BIT_VAPP_PREFIX)/doc/man/man1/pak.1 ; \
	mkdir -p "$(BIT_MAN_PREFIX)/man1" ; \
	rm -f "$(BIT_MAN_PREFIX)/man1/pak.1" ; \
	ln -s "$(BIT_VAPP_PREFIX)/doc/man/man1/pak.1" "$(BIT_MAN_PREFIX)/man1/pak.1" ; \
	)

#
#   start
#
start: $(DEPS_62)

#
#   install
#
DEPS_63 += stop
DEPS_63 += installBinary
DEPS_63 += start

install: $(DEPS_63)

#
#   uninstall
#
DEPS_64 += stop

uninstall: $(DEPS_64)
	( \
	cd .; \
	rm -fr "$(BIT_VAPP_PREFIX)" ; \
	rm -f "$(BIT_APP_PREFIX)/latest" ; \
	rmdir -p "$(BIT_APP_PREFIX)" 2>/dev/null ; true ; \
	)

