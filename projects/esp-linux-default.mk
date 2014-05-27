#
#   esp-linux-default.mk -- Makefile to build Embedthis ESP for linux
#

NAME                  := esp
VERSION               := 5.0.0-rc2
PROFILE               ?= default
ARCH                  ?= $(shell uname -m | sed 's/i.86/x86/;s/x86_64/x64/;s/arm.*/arm/;s/mips.*/mips/')
CC_ARCH               ?= $(shell echo $(ARCH) | sed 's/x86/i686/;s/x64/x86_64/')
OS                    ?= linux
CC                    ?= gcc
CONFIG                ?= $(OS)-$(ARCH)-$(PROFILE)
LBIN                  ?= $(CONFIG)/bin
PATH                  := $(LBIN):$(PATH)

ME_COM_APPWEB         ?= 1
ME_COM_CGI            ?= 0
ME_COM_DIR            ?= 0
ME_COM_EST            ?= 1
ME_COM_HTTP           ?= 1
ME_COM_MATRIXSSL      ?= 0
ME_COM_MDB            ?= 1
ME_COM_NANOSSL        ?= 0
ME_COM_OPENSSL        ?= 0
ME_COM_PCRE           ?= 1
ME_COM_SQLITE         ?= 1
ME_COM_SSL            ?= 1
ME_COM_VXWORKS        ?= 0
ME_COM_WINSDK         ?= 1

ifeq ($(ME_COM_EST),1)
    ME_COM_SSL := 1
endif
ifeq ($(ME_COM_MATRIXSSL),1)
    ME_COM_SSL := 1
endif
ifeq ($(ME_COM_NANOSSL),1)
    ME_COM_SSL := 1
endif
ifeq ($(ME_COM_OPENSSL),1)
    ME_COM_SSL := 1
endif

ME_COM_COMPILER_PATH  ?= gcc
ME_COM_LIB_PATH       ?= ar
ME_COM_MATRIXSSL_PATH ?= /usr/src/matrixssl
ME_COM_NANOSSL_PATH   ?= /usr/src/nanossl
ME_COM_OPENSSL_PATH   ?= /usr/src/openssl

CFLAGS                += -fPIC -w
DFLAGS                += -D_REENTRANT -DPIC $(patsubst %,-D%,$(filter ME_%,$(MAKEFLAGS))) -DME_COM_APPWEB=$(ME_COM_APPWEB) -DME_COM_CGI=$(ME_COM_CGI) -DME_COM_DIR=$(ME_COM_DIR) -DME_COM_EST=$(ME_COM_EST) -DME_COM_HTTP=$(ME_COM_HTTP) -DME_COM_MATRIXSSL=$(ME_COM_MATRIXSSL) -DME_COM_MDB=$(ME_COM_MDB) -DME_COM_NANOSSL=$(ME_COM_NANOSSL) -DME_COM_OPENSSL=$(ME_COM_OPENSSL) -DME_COM_PCRE=$(ME_COM_PCRE) -DME_COM_SQLITE=$(ME_COM_SQLITE) -DME_COM_SSL=$(ME_COM_SSL) -DME_COM_VXWORKS=$(ME_COM_VXWORKS) -DME_COM_WINSDK=$(ME_COM_WINSDK) 
IFLAGS                += "-I$(CONFIG)/inc"
LDFLAGS               += '-rdynamic' '-Wl,--enable-new-dtags' '-Wl,-rpath,$$ORIGIN/'
LIBPATHS              += -L$(CONFIG)/bin
LIBS                  += -lrt -ldl -lpthread -lm

DEBUG                 ?= debug
CFLAGS-debug          ?= -g
DFLAGS-debug          ?= -DME_DEBUG
LDFLAGS-debug         ?= -g
DFLAGS-release        ?= 
CFLAGS-release        ?= -O2
LDFLAGS-release       ?= 
CFLAGS                += $(CFLAGS-$(DEBUG))
DFLAGS                += $(DFLAGS-$(DEBUG))
LDFLAGS               += $(LDFLAGS-$(DEBUG))

ME_ROOT_PREFIX        ?= 
ME_BASE_PREFIX        ?= $(ME_ROOT_PREFIX)/usr/local
ME_DATA_PREFIX        ?= $(ME_ROOT_PREFIX)/
ME_STATE_PREFIX       ?= $(ME_ROOT_PREFIX)/var
ME_APP_PREFIX         ?= $(ME_BASE_PREFIX)/lib/$(NAME)
ME_VAPP_PREFIX        ?= $(ME_APP_PREFIX)/$(VERSION)
ME_BIN_PREFIX         ?= $(ME_ROOT_PREFIX)/usr/local/bin
ME_INC_PREFIX         ?= $(ME_ROOT_PREFIX)/usr/local/include
ME_LIB_PREFIX         ?= $(ME_ROOT_PREFIX)/usr/local/lib
ME_MAN_PREFIX         ?= $(ME_ROOT_PREFIX)/usr/local/share/man
ME_SBIN_PREFIX        ?= $(ME_ROOT_PREFIX)/usr/local/sbin
ME_ETC_PREFIX         ?= $(ME_ROOT_PREFIX)/etc/$(NAME)
ME_WEB_PREFIX         ?= $(ME_ROOT_PREFIX)/var/www/$(NAME)-default
ME_LOG_PREFIX         ?= $(ME_ROOT_PREFIX)/var/log/$(NAME)
ME_SPOOL_PREFIX       ?= $(ME_ROOT_PREFIX)/var/spool/$(NAME)
ME_CACHE_PREFIX       ?= $(ME_ROOT_PREFIX)/var/spool/$(NAME)/cache
ME_SRC_PREFIX         ?= $(ME_ROOT_PREFIX)$(NAME)-$(VERSION)


TARGETS               += $(CONFIG)/esp
TARGETS               += $(CONFIG)/bin/esp.conf
TARGETS               += $(CONFIG)/bin/esp
TARGETS               += $(CONFIG)/bin/ca.crt
ifeq ($(ME_COM_EST),1)
    TARGETS           += $(CONFIG)/bin/libest.so
endif
TARGETS               += $(CONFIG)/bin/libmprssl.so
TARGETS               += $(CONFIG)/bin/espman
ifeq ($(ME_COM_SQLITE),1)
    TARGETS           += $(CONFIG)/bin/sqlite
endif

unexport CDPATH

ifndef SHOW
.SILENT:
endif

all build compile: prep $(TARGETS)

.PHONY: prep

prep:
	@echo "      [Info] Use "make SHOW=1" to trace executed commands."
	@if [ "$(CONFIG)" = "" ] ; then echo WARNING: CONFIG not set ; exit 255 ; fi
	@if [ "$(ME_APP_PREFIX)" = "" ] ; then echo WARNING: ME_APP_PREFIX not set ; exit 255 ; fi
	@[ ! -x $(CONFIG)/bin ] && mkdir -p $(CONFIG)/bin; true
	@[ ! -x $(CONFIG)/inc ] && mkdir -p $(CONFIG)/inc; true
	@[ ! -x $(CONFIG)/obj ] && mkdir -p $(CONFIG)/obj; true
	@[ ! -f $(CONFIG)/inc/osdep.h ] && cp src/paks/osdep/osdep.h $(CONFIG)/inc/osdep.h ; true
	@if ! diff $(CONFIG)/inc/osdep.h src/paks/osdep/osdep.h >/dev/null ; then\
		cp src/paks/osdep/osdep.h $(CONFIG)/inc/osdep.h  ; \
	fi; true
	@[ ! -f $(CONFIG)/inc/me.h ] && cp projects/esp-linux-default-me.h $(CONFIG)/inc/me.h ; true
	@if ! diff $(CONFIG)/inc/me.h projects/esp-linux-default-me.h >/dev/null ; then\
		cp projects/esp-linux-default-me.h $(CONFIG)/inc/me.h  ; \
	fi; true
	@if [ -f "$(CONFIG)/.makeflags" ] ; then \
		if [ "$(MAKEFLAGS)" != " ` cat $(CONFIG)/.makeflags`" ] ; then \
			echo "   [Warning] Make flags have changed since the last build: "`cat $(CONFIG)/.makeflags`"" ; \
		fi ; \
	fi
	@echo $(MAKEFLAGS) >$(CONFIG)/.makeflags

clean:
	rm -f "$(CONFIG)/obj/appwebLib.o"
	rm -f "$(CONFIG)/obj/edi.o"
	rm -f "$(CONFIG)/obj/esp.o"
	rm -f "$(CONFIG)/obj/espAbbrev.o"
	rm -f "$(CONFIG)/obj/espConfig.o"
	rm -f "$(CONFIG)/obj/espFramework.o"
	rm -f "$(CONFIG)/obj/espHandler.o"
	rm -f "$(CONFIG)/obj/espHtml.o"
	rm -f "$(CONFIG)/obj/espTemplate.o"
	rm -f "$(CONFIG)/obj/estLib.o"
	rm -f "$(CONFIG)/obj/httpLib.o"
	rm -f "$(CONFIG)/obj/manager.o"
	rm -f "$(CONFIG)/obj/mdb.o"
	rm -f "$(CONFIG)/obj/mprLib.o"
	rm -f "$(CONFIG)/obj/mprSsl.o"
	rm -f "$(CONFIG)/obj/pcre.o"
	rm -f "$(CONFIG)/obj/sdb.o"
	rm -f "$(CONFIG)/obj/sqlite.o"
	rm -f "$(CONFIG)/obj/sqlite3.o"
	rm -f "$(CONFIG)/bin/esp.conf"
	rm -f "$(CONFIG)/bin/esp"
	rm -f "$(CONFIG)/bin/ca.crt"
	rm -f "$(CONFIG)/bin/libappweb.so"
	rm -f "$(CONFIG)/bin/libest.so"
	rm -f "$(CONFIG)/bin/libhttp.so"
	rm -f "$(CONFIG)/bin/libmod_esp.so"
	rm -f "$(CONFIG)/bin/libmpr.so"
	rm -f "$(CONFIG)/bin/libmprssl.so"
	rm -f "$(CONFIG)/bin/libpcre.so"
	rm -f "$(CONFIG)/bin/libsql.so"
	rm -f "$(CONFIG)/bin/espman"
	rm -f "$(CONFIG)/bin/sqlite"

clobber: clean
	rm -fr ./$(CONFIG)


#
#   esp-paks
#
DEPS_1 += src/paks/esp-html-mvc
DEPS_1 += src/paks/esp-html-mvc/client
DEPS_1 += src/paks/esp-html-mvc/client/assets
DEPS_1 += src/paks/esp-html-mvc/client/assets/favicon.ico
DEPS_1 += src/paks/esp-html-mvc/client/css
DEPS_1 += src/paks/esp-html-mvc/client/css/all.css
DEPS_1 += src/paks/esp-html-mvc/client/css/all.less
DEPS_1 += src/paks/esp-html-mvc/client/index.esp
DEPS_1 += src/paks/esp-html-mvc/css
DEPS_1 += src/paks/esp-html-mvc/css/app.less
DEPS_1 += src/paks/esp-html-mvc/css/theme.less
DEPS_1 += src/paks/esp-html-mvc/generate
DEPS_1 += src/paks/esp-html-mvc/generate/appweb.conf
DEPS_1 += src/paks/esp-html-mvc/generate/controller.c
DEPS_1 += src/paks/esp-html-mvc/generate/controllerSingleton.c
DEPS_1 += src/paks/esp-html-mvc/generate/edit.esp
DEPS_1 += src/paks/esp-html-mvc/generate/list.esp
DEPS_1 += src/paks/esp-html-mvc/layouts
DEPS_1 += src/paks/esp-html-mvc/layouts/default.esp
DEPS_1 += src/paks/esp-html-mvc/LICENSE.md
DEPS_1 += src/paks/esp-html-mvc/package.json
DEPS_1 += src/paks/esp-html-mvc/README.md
DEPS_1 += src/paks/esp-mvc
DEPS_1 += src/paks/esp-mvc/generate
DEPS_1 += src/paks/esp-mvc/generate/appweb.conf
DEPS_1 += src/paks/esp-mvc/generate/controller.c
DEPS_1 += src/paks/esp-mvc/generate/migration.c
DEPS_1 += src/paks/esp-mvc/generate/src
DEPS_1 += src/paks/esp-mvc/generate/src/app.c
DEPS_1 += src/paks/esp-mvc/LICENSE.md
DEPS_1 += src/paks/esp-mvc/package.json
DEPS_1 += src/paks/esp-mvc/README.md
DEPS_1 += src/paks/esp-server
DEPS_1 += src/paks/esp-server/generate
DEPS_1 += src/paks/esp-server/generate/appweb.conf
DEPS_1 += src/paks/esp-server/LICENSE.md
DEPS_1 += src/paks/esp-server/package.json
DEPS_1 += src/paks/esp-server/README.md

$(CONFIG)/esp: $(DEPS_1)
	( \
	cd src/paks; \
	mkdir -p "../../$(CONFIG)/esp/esp-html-mvc/5.0.0-rc2" ; \
	mkdir -p "../../$(CONFIG)/esp/esp-html-mvc/5.0.0-rc2/client" ; \
	mkdir -p "../../$(CONFIG)/esp/esp-html-mvc/5.0.0-rc2/client/assets" ; \
	cp esp-html-mvc/client/assets/favicon.ico ../../$(CONFIG)/esp/esp-html-mvc/5.0.0-rc2/client/assets/favicon.ico ; \
	mkdir -p "../../$(CONFIG)/esp/esp-html-mvc/5.0.0-rc2/client/css" ; \
	cp esp-html-mvc/client/css/all.css ../../$(CONFIG)/esp/esp-html-mvc/5.0.0-rc2/client/css/all.css ; \
	cp esp-html-mvc/client/css/all.less ../../$(CONFIG)/esp/esp-html-mvc/5.0.0-rc2/client/css/all.less ; \
	cp esp-html-mvc/client/index.esp ../../$(CONFIG)/esp/esp-html-mvc/5.0.0-rc2/client/index.esp ; \
	mkdir -p "../../$(CONFIG)/esp/esp-html-mvc/5.0.0-rc2/css" ; \
	cp esp-html-mvc/css/app.less ../../$(CONFIG)/esp/esp-html-mvc/5.0.0-rc2/css/app.less ; \
	cp esp-html-mvc/css/theme.less ../../$(CONFIG)/esp/esp-html-mvc/5.0.0-rc2/css/theme.less ; \
	mkdir -p "../../$(CONFIG)/esp/esp-html-mvc/5.0.0-rc2/generate" ; \
	cp esp-html-mvc/generate/appweb.conf ../../$(CONFIG)/esp/esp-html-mvc/5.0.0-rc2/generate/appweb.conf ; \
	cp esp-html-mvc/generate/controller.c ../../$(CONFIG)/esp/esp-html-mvc/5.0.0-rc2/generate/controller.c ; \
	cp esp-html-mvc/generate/controllerSingleton.c ../../$(CONFIG)/esp/esp-html-mvc/5.0.0-rc2/generate/controllerSingleton.c ; \
	cp esp-html-mvc/generate/edit.esp ../../$(CONFIG)/esp/esp-html-mvc/5.0.0-rc2/generate/edit.esp ; \
	cp esp-html-mvc/generate/list.esp ../../$(CONFIG)/esp/esp-html-mvc/5.0.0-rc2/generate/list.esp ; \
	mkdir -p "../../$(CONFIG)/esp/esp-html-mvc/5.0.0-rc2/layouts" ; \
	cp esp-html-mvc/layouts/default.esp ../../$(CONFIG)/esp/esp-html-mvc/5.0.0-rc2/layouts/default.esp ; \
	cp esp-html-mvc/LICENSE.md ../../$(CONFIG)/esp/esp-html-mvc/5.0.0-rc2/LICENSE.md ; \
	cp esp-html-mvc/package.json ../../$(CONFIG)/esp/esp-html-mvc/5.0.0-rc2/package.json ; \
	cp esp-html-mvc/README.md ../../$(CONFIG)/esp/esp-html-mvc/5.0.0-rc2/README.md ; \
	mkdir -p "../../$(CONFIG)/esp/esp-mvc/5.0.0-rc2" ; \
	mkdir -p "../../$(CONFIG)/esp/esp-mvc/5.0.0-rc2/generate" ; \
	cp esp-mvc/generate/appweb.conf ../../$(CONFIG)/esp/esp-mvc/5.0.0-rc2/generate/appweb.conf ; \
	cp esp-mvc/generate/controller.c ../../$(CONFIG)/esp/esp-mvc/5.0.0-rc2/generate/controller.c ; \
	cp esp-mvc/generate/migration.c ../../$(CONFIG)/esp/esp-mvc/5.0.0-rc2/generate/migration.c ; \
	mkdir -p "../../$(CONFIG)/esp/esp-mvc/5.0.0-rc2/generate/src" ; \
	cp esp-mvc/generate/src/app.c ../../$(CONFIG)/esp/esp-mvc/5.0.0-rc2/generate/src/app.c ; \
	cp esp-mvc/LICENSE.md ../../$(CONFIG)/esp/esp-mvc/5.0.0-rc2/LICENSE.md ; \
	cp esp-mvc/package.json ../../$(CONFIG)/esp/esp-mvc/5.0.0-rc2/package.json ; \
	cp esp-mvc/README.md ../../$(CONFIG)/esp/esp-mvc/5.0.0-rc2/README.md ; \
	mkdir -p "../../$(CONFIG)/esp/esp-server/5.0.0-rc2" ; \
	mkdir -p "../../$(CONFIG)/esp/esp-server/5.0.0-rc2/generate" ; \
	cp esp-server/generate/appweb.conf ../../$(CONFIG)/esp/esp-server/5.0.0-rc2/generate/appweb.conf ; \
	cp esp-server/LICENSE.md ../../$(CONFIG)/esp/esp-server/5.0.0-rc2/LICENSE.md ; \
	cp esp-server/package.json ../../$(CONFIG)/esp/esp-server/5.0.0-rc2/package.json ; \
	cp esp-server/README.md ../../$(CONFIG)/esp/esp-server/5.0.0-rc2/README.md ; \
	)

#
#   esp.conf
#
DEPS_2 += src/esp.conf

$(CONFIG)/bin/esp.conf: $(DEPS_2)
	@echo '      [Copy] $(CONFIG)/bin/esp.conf'
	mkdir -p "$(CONFIG)/bin"
	cp src/esp.conf $(CONFIG)/bin/esp.conf

#
#   mpr.h
#
$(CONFIG)/inc/mpr.h: $(DEPS_3)
	@echo '      [Copy] $(CONFIG)/inc/mpr.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/paks/mpr/mpr.h $(CONFIG)/inc/mpr.h

#
#   me.h
#
$(CONFIG)/inc/me.h: $(DEPS_4)
	@echo '      [Copy] $(CONFIG)/inc/me.h'

#
#   osdep.h
#
$(CONFIG)/inc/osdep.h: $(DEPS_5)
	@echo '      [Copy] $(CONFIG)/inc/osdep.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/paks/osdep/osdep.h $(CONFIG)/inc/osdep.h

#
#   mprLib.o
#
DEPS_6 += $(CONFIG)/inc/me.h
DEPS_6 += $(CONFIG)/inc/mpr.h
DEPS_6 += $(CONFIG)/inc/osdep.h

$(CONFIG)/obj/mprLib.o: \
    src/paks/mpr/mprLib.c $(DEPS_6)
	@echo '   [Compile] $(CONFIG)/obj/mprLib.o'
	$(CC) -c -o $(CONFIG)/obj/mprLib.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/paks/mpr/mprLib.c

#
#   libmpr
#
DEPS_7 += $(CONFIG)/inc/mpr.h
DEPS_7 += $(CONFIG)/inc/me.h
DEPS_7 += $(CONFIG)/inc/osdep.h
DEPS_7 += $(CONFIG)/obj/mprLib.o

$(CONFIG)/bin/libmpr.so: $(DEPS_7)
	@echo '      [Link] $(CONFIG)/bin/libmpr.so'
	$(CC) -shared -o $(CONFIG)/bin/libmpr.so $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/mprLib.o" $(LIBS) 

#
#   pcre.h
#
$(CONFIG)/inc/pcre.h: $(DEPS_8)
	@echo '      [Copy] $(CONFIG)/inc/pcre.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/paks/pcre/pcre.h $(CONFIG)/inc/pcre.h

#
#   pcre.o
#
DEPS_9 += $(CONFIG)/inc/me.h
DEPS_9 += $(CONFIG)/inc/pcre.h

$(CONFIG)/obj/pcre.o: \
    src/paks/pcre/pcre.c $(DEPS_9)
	@echo '   [Compile] $(CONFIG)/obj/pcre.o'
	$(CC) -c -o $(CONFIG)/obj/pcre.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/paks/pcre/pcre.c

ifeq ($(ME_COM_PCRE),1)
#
#   libpcre
#
DEPS_10 += $(CONFIG)/inc/pcre.h
DEPS_10 += $(CONFIG)/inc/me.h
DEPS_10 += $(CONFIG)/obj/pcre.o

$(CONFIG)/bin/libpcre.so: $(DEPS_10)
	@echo '      [Link] $(CONFIG)/bin/libpcre.so'
	$(CC) -shared -o $(CONFIG)/bin/libpcre.so $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/pcre.o" $(LIBS) 
endif

#
#   http.h
#
$(CONFIG)/inc/http.h: $(DEPS_11)
	@echo '      [Copy] $(CONFIG)/inc/http.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/paks/http/http.h $(CONFIG)/inc/http.h

#
#   httpLib.o
#
DEPS_12 += $(CONFIG)/inc/me.h
DEPS_12 += $(CONFIG)/inc/http.h
DEPS_12 += $(CONFIG)/inc/mpr.h

$(CONFIG)/obj/httpLib.o: \
    src/paks/http/httpLib.c $(DEPS_12)
	@echo '   [Compile] $(CONFIG)/obj/httpLib.o'
	$(CC) -c -o $(CONFIG)/obj/httpLib.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/paks/http/httpLib.c

ifeq ($(ME_COM_HTTP),1)
#
#   libhttp
#
DEPS_13 += $(CONFIG)/inc/mpr.h
DEPS_13 += $(CONFIG)/inc/me.h
DEPS_13 += $(CONFIG)/inc/osdep.h
DEPS_13 += $(CONFIG)/obj/mprLib.o
DEPS_13 += $(CONFIG)/bin/libmpr.so
DEPS_13 += $(CONFIG)/inc/pcre.h
DEPS_13 += $(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_13 += $(CONFIG)/bin/libpcre.so
endif
DEPS_13 += $(CONFIG)/inc/http.h
DEPS_13 += $(CONFIG)/obj/httpLib.o

LIBS_13 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_13 += -lpcre
endif

$(CONFIG)/bin/libhttp.so: $(DEPS_13)
	@echo '      [Link] $(CONFIG)/bin/libhttp.so'
	$(CC) -shared -o $(CONFIG)/bin/libhttp.so $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/httpLib.o" $(LIBPATHS_13) $(LIBS_13) $(LIBS_13) $(LIBS) 
endif

#
#   appweb.h
#
$(CONFIG)/inc/appweb.h: $(DEPS_14)
	@echo '      [Copy] $(CONFIG)/inc/appweb.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/paks/appweb/appweb.h $(CONFIG)/inc/appweb.h

#
#   appwebLib.o
#
DEPS_15 += $(CONFIG)/inc/me.h
DEPS_15 += $(CONFIG)/inc/appweb.h
DEPS_15 += $(CONFIG)/inc/pcre.h
DEPS_15 += $(CONFIG)/inc/mpr.h
DEPS_15 += $(CONFIG)/inc/http.h

$(CONFIG)/obj/appwebLib.o: \
    src/paks/appweb/appwebLib.c $(DEPS_15)
	@echo '   [Compile] $(CONFIG)/obj/appwebLib.o'
	$(CC) -c -o $(CONFIG)/obj/appwebLib.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/paks/appweb/appwebLib.c

ifeq ($(ME_COM_APPWEB),1)
#
#   libappweb
#
DEPS_16 += $(CONFIG)/inc/mpr.h
DEPS_16 += $(CONFIG)/inc/me.h
DEPS_16 += $(CONFIG)/inc/osdep.h
DEPS_16 += $(CONFIG)/obj/mprLib.o
DEPS_16 += $(CONFIG)/bin/libmpr.so
DEPS_16 += $(CONFIG)/inc/pcre.h
DEPS_16 += $(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_16 += $(CONFIG)/bin/libpcre.so
endif
DEPS_16 += $(CONFIG)/inc/http.h
DEPS_16 += $(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_16 += $(CONFIG)/bin/libhttp.so
endif
DEPS_16 += $(CONFIG)/inc/appweb.h
DEPS_16 += $(CONFIG)/obj/appwebLib.o

ifeq ($(ME_COM_HTTP),1)
    LIBS_16 += -lhttp
endif
LIBS_16 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_16 += -lpcre
endif

$(CONFIG)/bin/libappweb.so: $(DEPS_16)
	@echo '      [Link] $(CONFIG)/bin/libappweb.so'
	$(CC) -shared -o $(CONFIG)/bin/libappweb.so $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/appwebLib.o" $(LIBPATHS_16) $(LIBS_16) $(LIBS_16) $(LIBS) 
endif

#
#   sqlite3.h
#
$(CONFIG)/inc/sqlite3.h: $(DEPS_17)
	@echo '      [Copy] $(CONFIG)/inc/sqlite3.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/paks/sqlite/sqlite3.h $(CONFIG)/inc/sqlite3.h

#
#   sqlite3.o
#
DEPS_18 += $(CONFIG)/inc/me.h
DEPS_18 += $(CONFIG)/inc/sqlite3.h

$(CONFIG)/obj/sqlite3.o: \
    src/paks/sqlite/sqlite3.c $(DEPS_18)
	@echo '   [Compile] $(CONFIG)/obj/sqlite3.o'
	$(CC) -c -o $(CONFIG)/obj/sqlite3.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/paks/sqlite/sqlite3.c

ifeq ($(ME_COM_SQLITE),1)
#
#   libsql
#
DEPS_19 += $(CONFIG)/inc/sqlite3.h
DEPS_19 += $(CONFIG)/inc/me.h
DEPS_19 += $(CONFIG)/obj/sqlite3.o

$(CONFIG)/bin/libsql.so: $(DEPS_19)
	@echo '      [Link] $(CONFIG)/bin/libsql.so'
	$(CC) -shared -o $(CONFIG)/bin/libsql.so $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/sqlite3.o" $(LIBS) 
endif

#
#   edi.h
#
$(CONFIG)/inc/edi.h: $(DEPS_20)
	@echo '      [Copy] $(CONFIG)/inc/edi.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/edi.h $(CONFIG)/inc/edi.h

#
#   esp.h
#
$(CONFIG)/inc/esp.h: $(DEPS_21)
	@echo '      [Copy] $(CONFIG)/inc/esp.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/esp.h $(CONFIG)/inc/esp.h

#
#   mdb.h
#
$(CONFIG)/inc/mdb.h: $(DEPS_22)
	@echo '      [Copy] $(CONFIG)/inc/mdb.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/mdb.h $(CONFIG)/inc/mdb.h

#
#   edi.o
#
DEPS_23 += $(CONFIG)/inc/me.h
DEPS_23 += $(CONFIG)/inc/edi.h
DEPS_23 += $(CONFIG)/inc/pcre.h
DEPS_23 += $(CONFIG)/inc/http.h

$(CONFIG)/obj/edi.o: \
    src/edi.c $(DEPS_23)
	@echo '   [Compile] $(CONFIG)/obj/edi.o'
	$(CC) -c -o $(CONFIG)/obj/edi.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/edi.c

#
#   espAbbrev.o
#
DEPS_24 += $(CONFIG)/inc/me.h
DEPS_24 += $(CONFIG)/inc/esp.h
DEPS_24 += $(CONFIG)/inc/appweb.h
DEPS_24 += $(CONFIG)/inc/edi.h

$(CONFIG)/obj/espAbbrev.o: \
    src/espAbbrev.c $(DEPS_24)
	@echo '   [Compile] $(CONFIG)/obj/espAbbrev.o'
	$(CC) -c -o $(CONFIG)/obj/espAbbrev.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/espAbbrev.c

#
#   espConfig.o
#
DEPS_25 += $(CONFIG)/inc/me.h
DEPS_25 += $(CONFIG)/inc/esp.h

$(CONFIG)/obj/espConfig.o: \
    src/espConfig.c $(DEPS_25)
	@echo '   [Compile] $(CONFIG)/obj/espConfig.o'
	$(CC) -c -o $(CONFIG)/obj/espConfig.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/espConfig.c

#
#   espFramework.o
#
DEPS_26 += $(CONFIG)/inc/me.h
DEPS_26 += $(CONFIG)/inc/esp.h

$(CONFIG)/obj/espFramework.o: \
    src/espFramework.c $(DEPS_26)
	@echo '   [Compile] $(CONFIG)/obj/espFramework.o'
	$(CC) -c -o $(CONFIG)/obj/espFramework.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/espFramework.c

#
#   espHandler.o
#
DEPS_27 += $(CONFIG)/inc/me.h
DEPS_27 += $(CONFIG)/inc/esp.h

$(CONFIG)/obj/espHandler.o: \
    src/espHandler.c $(DEPS_27)
	@echo '   [Compile] $(CONFIG)/obj/espHandler.o'
	$(CC) -c -o $(CONFIG)/obj/espHandler.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/espHandler.c

#
#   espHtml.o
#
DEPS_28 += $(CONFIG)/inc/me.h
DEPS_28 += $(CONFIG)/inc/esp.h
DEPS_28 += $(CONFIG)/inc/edi.h

$(CONFIG)/obj/espHtml.o: \
    src/espHtml.c $(DEPS_28)
	@echo '   [Compile] $(CONFIG)/obj/espHtml.o'
	$(CC) -c -o $(CONFIG)/obj/espHtml.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/espHtml.c

#
#   espTemplate.o
#
DEPS_29 += $(CONFIG)/inc/me.h
DEPS_29 += $(CONFIG)/inc/esp.h

$(CONFIG)/obj/espTemplate.o: \
    src/espTemplate.c $(DEPS_29)
	@echo '   [Compile] $(CONFIG)/obj/espTemplate.o'
	$(CC) -c -o $(CONFIG)/obj/espTemplate.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/espTemplate.c

#
#   mdb.o
#
DEPS_30 += $(CONFIG)/inc/me.h
DEPS_30 += $(CONFIG)/inc/http.h
DEPS_30 += $(CONFIG)/inc/edi.h
DEPS_30 += $(CONFIG)/inc/mdb.h
DEPS_30 += $(CONFIG)/inc/pcre.h

$(CONFIG)/obj/mdb.o: \
    src/mdb.c $(DEPS_30)
	@echo '   [Compile] $(CONFIG)/obj/mdb.o'
	$(CC) -c -o $(CONFIG)/obj/mdb.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/mdb.c

#
#   sdb.o
#
DEPS_31 += $(CONFIG)/inc/me.h
DEPS_31 += $(CONFIG)/inc/http.h
DEPS_31 += $(CONFIG)/inc/edi.h

$(CONFIG)/obj/sdb.o: \
    src/sdb.c $(DEPS_31)
	@echo '   [Compile] $(CONFIG)/obj/sdb.o'
	$(CC) -c -o $(CONFIG)/obj/sdb.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/sdb.c

#
#   libmod_esp
#
DEPS_32 += $(CONFIG)/inc/mpr.h
DEPS_32 += $(CONFIG)/inc/me.h
DEPS_32 += $(CONFIG)/inc/osdep.h
DEPS_32 += $(CONFIG)/obj/mprLib.o
DEPS_32 += $(CONFIG)/bin/libmpr.so
DEPS_32 += $(CONFIG)/inc/pcre.h
DEPS_32 += $(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_32 += $(CONFIG)/bin/libpcre.so
endif
DEPS_32 += $(CONFIG)/inc/http.h
DEPS_32 += $(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_32 += $(CONFIG)/bin/libhttp.so
endif
DEPS_32 += $(CONFIG)/inc/appweb.h
DEPS_32 += $(CONFIG)/obj/appwebLib.o
ifeq ($(ME_COM_APPWEB),1)
    DEPS_32 += $(CONFIG)/bin/libappweb.so
endif
DEPS_32 += $(CONFIG)/inc/sqlite3.h
DEPS_32 += $(CONFIG)/obj/sqlite3.o
ifeq ($(ME_COM_SQLITE),1)
    DEPS_32 += $(CONFIG)/bin/libsql.so
endif
DEPS_32 += $(CONFIG)/inc/edi.h
DEPS_32 += $(CONFIG)/inc/esp.h
DEPS_32 += $(CONFIG)/inc/mdb.h
DEPS_32 += $(CONFIG)/obj/edi.o
DEPS_32 += $(CONFIG)/obj/espAbbrev.o
DEPS_32 += $(CONFIG)/obj/espConfig.o
DEPS_32 += $(CONFIG)/obj/espFramework.o
DEPS_32 += $(CONFIG)/obj/espHandler.o
DEPS_32 += $(CONFIG)/obj/espHtml.o
DEPS_32 += $(CONFIG)/obj/espTemplate.o
DEPS_32 += $(CONFIG)/obj/mdb.o
DEPS_32 += $(CONFIG)/obj/sdb.o

ifeq ($(ME_COM_APPWEB),1)
    LIBS_32 += -lappweb
endif
ifeq ($(ME_COM_HTTP),1)
    LIBS_32 += -lhttp
endif
LIBS_32 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_32 += -lpcre
endif
ifeq ($(ME_COM_SQLITE),1)
    LIBS_32 += -lsql
endif

$(CONFIG)/bin/libmod_esp.so: $(DEPS_32)
	@echo '      [Link] $(CONFIG)/bin/libmod_esp.so'
	$(CC) -shared -o $(CONFIG)/bin/libmod_esp.so $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/edi.o" "$(CONFIG)/obj/espAbbrev.o" "$(CONFIG)/obj/espConfig.o" "$(CONFIG)/obj/espFramework.o" "$(CONFIG)/obj/espHandler.o" "$(CONFIG)/obj/espHtml.o" "$(CONFIG)/obj/espTemplate.o" "$(CONFIG)/obj/mdb.o" "$(CONFIG)/obj/sdb.o" $(LIBPATHS_32) $(LIBS_32) $(LIBS_32) $(LIBS) 

#
#   esp.o
#
DEPS_33 += $(CONFIG)/inc/me.h
DEPS_33 += $(CONFIG)/inc/esp.h

$(CONFIG)/obj/esp.o: \
    src/esp.c $(DEPS_33)
	@echo '   [Compile] $(CONFIG)/obj/esp.o'
	$(CC) -c -o $(CONFIG)/obj/esp.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/esp.c

#
#   espcmd
#
DEPS_34 += $(CONFIG)/inc/mpr.h
DEPS_34 += $(CONFIG)/inc/me.h
DEPS_34 += $(CONFIG)/inc/osdep.h
DEPS_34 += $(CONFIG)/obj/mprLib.o
DEPS_34 += $(CONFIG)/bin/libmpr.so
DEPS_34 += $(CONFIG)/inc/pcre.h
DEPS_34 += $(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_34 += $(CONFIG)/bin/libpcre.so
endif
DEPS_34 += $(CONFIG)/inc/http.h
DEPS_34 += $(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_34 += $(CONFIG)/bin/libhttp.so
endif
DEPS_34 += $(CONFIG)/inc/appweb.h
DEPS_34 += $(CONFIG)/obj/appwebLib.o
ifeq ($(ME_COM_APPWEB),1)
    DEPS_34 += $(CONFIG)/bin/libappweb.so
endif
DEPS_34 += $(CONFIG)/inc/sqlite3.h
DEPS_34 += $(CONFIG)/obj/sqlite3.o
ifeq ($(ME_COM_SQLITE),1)
    DEPS_34 += $(CONFIG)/bin/libsql.so
endif
DEPS_34 += $(CONFIG)/inc/edi.h
DEPS_34 += $(CONFIG)/inc/esp.h
DEPS_34 += $(CONFIG)/inc/mdb.h
DEPS_34 += $(CONFIG)/obj/edi.o
DEPS_34 += $(CONFIG)/obj/espAbbrev.o
DEPS_34 += $(CONFIG)/obj/espConfig.o
DEPS_34 += $(CONFIG)/obj/espFramework.o
DEPS_34 += $(CONFIG)/obj/espHandler.o
DEPS_34 += $(CONFIG)/obj/espHtml.o
DEPS_34 += $(CONFIG)/obj/espTemplate.o
DEPS_34 += $(CONFIG)/obj/mdb.o
DEPS_34 += $(CONFIG)/obj/sdb.o
DEPS_34 += $(CONFIG)/bin/libmod_esp.so
DEPS_34 += $(CONFIG)/obj/esp.o

ifeq ($(ME_COM_APPWEB),1)
    LIBS_34 += -lappweb
endif
ifeq ($(ME_COM_HTTP),1)
    LIBS_34 += -lhttp
endif
LIBS_34 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_34 += -lpcre
endif
ifeq ($(ME_COM_SQLITE),1)
    LIBS_34 += -lsql
endif
LIBS_34 += -lmod_esp

$(CONFIG)/bin/esp: $(DEPS_34)
	@echo '      [Link] $(CONFIG)/bin/esp'
	$(CC) -o $(CONFIG)/bin/esp $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/esp.o" $(LIBPATHS_34) $(LIBS_34) $(LIBS_34) $(LIBS) $(LIBS) 


#
#   http-ca-crt
#
DEPS_35 += src/paks/http/ca.crt

$(CONFIG)/bin/ca.crt: $(DEPS_35)
	@echo '      [Copy] $(CONFIG)/bin/ca.crt'
	mkdir -p "$(CONFIG)/bin"
	cp src/paks/http/ca.crt $(CONFIG)/bin/ca.crt

#
#   est.h
#
$(CONFIG)/inc/est.h: $(DEPS_36)
	@echo '      [Copy] $(CONFIG)/inc/est.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/paks/est/est.h $(CONFIG)/inc/est.h

#
#   estLib.o
#
DEPS_37 += $(CONFIG)/inc/me.h
DEPS_37 += $(CONFIG)/inc/est.h
DEPS_37 += $(CONFIG)/inc/osdep.h

$(CONFIG)/obj/estLib.o: \
    src/paks/est/estLib.c $(DEPS_37)
	@echo '   [Compile] $(CONFIG)/obj/estLib.o'
	$(CC) -c -o $(CONFIG)/obj/estLib.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/paks/est/estLib.c

ifeq ($(ME_COM_EST),1)
#
#   libest
#
DEPS_38 += $(CONFIG)/inc/est.h
DEPS_38 += $(CONFIG)/inc/me.h
DEPS_38 += $(CONFIG)/inc/osdep.h
DEPS_38 += $(CONFIG)/obj/estLib.o

$(CONFIG)/bin/libest.so: $(DEPS_38)
	@echo '      [Link] $(CONFIG)/bin/libest.so'
	$(CC) -shared -o $(CONFIG)/bin/libest.so $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/estLib.o" $(LIBS) 
endif

#
#   mprSsl.o
#
DEPS_39 += $(CONFIG)/inc/me.h
DEPS_39 += $(CONFIG)/inc/mpr.h
DEPS_39 += $(CONFIG)/inc/est.h

$(CONFIG)/obj/mprSsl.o: \
    src/paks/mpr/mprSsl.c $(DEPS_39)
	@echo '   [Compile] $(CONFIG)/obj/mprSsl.o'
	$(CC) -c -o $(CONFIG)/obj/mprSsl.o $(CFLAGS) $(DFLAGS) $(IFLAGS) "-I$(ME_COM_OPENSSL_PATH)/include" "-I$(ME_COM_MATRIXSSL_PATH)" "-I$(ME_COM_MATRIXSSL_PATH)/matrixssl" "-I$(ME_COM_NANOSSL_PATH)/src" src/paks/mpr/mprSsl.c

#
#   libmprssl
#
DEPS_40 += $(CONFIG)/inc/mpr.h
DEPS_40 += $(CONFIG)/inc/me.h
DEPS_40 += $(CONFIG)/inc/osdep.h
DEPS_40 += $(CONFIG)/obj/mprLib.o
DEPS_40 += $(CONFIG)/bin/libmpr.so
DEPS_40 += $(CONFIG)/inc/est.h
DEPS_40 += $(CONFIG)/obj/estLib.o
ifeq ($(ME_COM_EST),1)
    DEPS_40 += $(CONFIG)/bin/libest.so
endif
DEPS_40 += $(CONFIG)/obj/mprSsl.o

LIBS_40 += -lmpr
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_40 += -lssl
    LIBPATHS_40 += -L$(ME_COM_OPENSSL_PATH)
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_40 += -lcrypto
    LIBPATHS_40 += -L$(ME_COM_OPENSSL_PATH)
endif
ifeq ($(ME_COM_EST),1)
    LIBS_40 += -lest
endif
ifeq ($(ME_COM_MATRIXSSL),1)
    LIBS_40 += -lmatrixssl
    LIBPATHS_40 += -L$(ME_COM_MATRIXSSL_PATH)
endif
ifeq ($(ME_COM_NANOSSL),1)
    LIBS_40 += -lssls
    LIBPATHS_40 += -L$(ME_COM_NANOSSL_PATH)/bin
endif

$(CONFIG)/bin/libmprssl.so: $(DEPS_40)
	@echo '      [Link] $(CONFIG)/bin/libmprssl.so'
	$(CC) -shared -o $(CONFIG)/bin/libmprssl.so $(LDFLAGS) $(LIBPATHS)    "$(CONFIG)/obj/mprSsl.o" $(LIBPATHS_40) $(LIBS_40) $(LIBS_40) $(LIBS) 

#
#   manager.o
#
DEPS_41 += $(CONFIG)/inc/me.h
DEPS_41 += $(CONFIG)/inc/mpr.h

$(CONFIG)/obj/manager.o: \
    src/paks/mpr/manager.c $(DEPS_41)
	@echo '   [Compile] $(CONFIG)/obj/manager.o'
	$(CC) -c -o $(CONFIG)/obj/manager.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/paks/mpr/manager.c

#
#   manager
#
DEPS_42 += $(CONFIG)/inc/mpr.h
DEPS_42 += $(CONFIG)/inc/me.h
DEPS_42 += $(CONFIG)/inc/osdep.h
DEPS_42 += $(CONFIG)/obj/mprLib.o
DEPS_42 += $(CONFIG)/bin/libmpr.so
DEPS_42 += $(CONFIG)/obj/manager.o

LIBS_42 += -lmpr

$(CONFIG)/bin/espman: $(DEPS_42)
	@echo '      [Link] $(CONFIG)/bin/espman'
	$(CC) -o $(CONFIG)/bin/espman $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/manager.o" $(LIBPATHS_42) $(LIBS_42) $(LIBS_42) $(LIBS) $(LIBS) 

#
#   sqlite.o
#
DEPS_43 += $(CONFIG)/inc/me.h
DEPS_43 += $(CONFIG)/inc/sqlite3.h

$(CONFIG)/obj/sqlite.o: \
    src/paks/sqlite/sqlite.c $(DEPS_43)
	@echo '   [Compile] $(CONFIG)/obj/sqlite.o'
	$(CC) -c -o $(CONFIG)/obj/sqlite.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/paks/sqlite/sqlite.c

ifeq ($(ME_COM_SQLITE),1)
#
#   sqliteshell
#
DEPS_44 += $(CONFIG)/inc/sqlite3.h
DEPS_44 += $(CONFIG)/inc/me.h
DEPS_44 += $(CONFIG)/obj/sqlite3.o
DEPS_44 += $(CONFIG)/bin/libsql.so
DEPS_44 += $(CONFIG)/obj/sqlite.o

LIBS_44 += -lsql

$(CONFIG)/bin/sqlite: $(DEPS_44)
	@echo '      [Link] $(CONFIG)/bin/sqlite'
	$(CC) -o $(CONFIG)/bin/sqlite $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/sqlite.o" $(LIBPATHS_44) $(LIBS_44) $(LIBS_44) $(LIBS) $(LIBS) 
endif

#
#   stop
#
stop: $(DEPS_45)

#
#   installBinary
#
installBinary: $(DEPS_46)
	( \
	cd .; \
	mkdir -p "$(ME_APP_PREFIX)" ; \
	rm -f "$(ME_APP_PREFIX)/latest" ; \
	ln -s "5.0.0-rc2" "$(ME_APP_PREFIX)/latest" ; \
	mkdir -p "$(ME_VAPP_PREFIX)/bin" ; \
	cp $(CONFIG)/bin/esp $(ME_VAPP_PREFIX)/bin/esp ; \
	mkdir -p "$(ME_BIN_PREFIX)" ; \
	rm -f "$(ME_BIN_PREFIX)/esp" ; \
	ln -s "$(ME_VAPP_PREFIX)/bin/esp" "$(ME_BIN_PREFIX)/esp" ; \
	cp $(CONFIG)/bin/espman $(ME_VAPP_PREFIX)/bin/espman ; \
	rm -f "$(ME_BIN_PREFIX)/espman" ; \
	ln -s "$(ME_VAPP_PREFIX)/bin/espman" "$(ME_BIN_PREFIX)/espman" ; \
	cp $(CONFIG)/bin/libappweb.so $(ME_VAPP_PREFIX)/bin/libappweb.so ; \
	cp $(CONFIG)/bin/libhttp.so $(ME_VAPP_PREFIX)/bin/libhttp.so ; \
	cp $(CONFIG)/bin/libmpr.so $(ME_VAPP_PREFIX)/bin/libmpr.so ; \
	cp $(CONFIG)/bin/libmprssl.so $(ME_VAPP_PREFIX)/bin/libmprssl.so ; \
	cp $(CONFIG)/bin/libpcre.so $(ME_VAPP_PREFIX)/bin/libpcre.so ; \
	cp $(CONFIG)/bin/libsql.so $(ME_VAPP_PREFIX)/bin/libsql.so ; \
	cp $(CONFIG)/bin/libmod_esp.so $(ME_VAPP_PREFIX)/bin/libmod_esp.so ; \
	if [ "$(ME_COM_OPENSSL)" = 1 ]; then true ; \
	cp $(CONFIG)/bin/libssl*.so* $(ME_VAPP_PREFIX)/bin/libssl*.so* ; \
	cp $(CONFIG)/bin/libcrypto*.so* $(ME_VAPP_PREFIX)/bin/libcrypto*.so* ; \
	fi ; \
	if [ "$(ME_COM_EST)" = 1 ]; then true ; \
	cp $(CONFIG)/bin/libest.so $(ME_VAPP_PREFIX)/bin/libest.so ; \
	fi ; \
	cp $(CONFIG)/bin/ca.crt $(ME_VAPP_PREFIX)/bin/ca.crt ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.0.0-rc2" ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.0.0-rc2/client" ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.0.0-rc2/client/assets" ; \
	cp src/paks/esp-html-mvc/client/assets/favicon.ico $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.0.0-rc2/client/assets/favicon.ico ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.0.0-rc2/client/css" ; \
	cp src/paks/esp-html-mvc/client/css/all.css $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.0.0-rc2/client/css/all.css ; \
	cp src/paks/esp-html-mvc/client/css/all.less $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.0.0-rc2/client/css/all.less ; \
	cp src/paks/esp-html-mvc/client/index.esp $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.0.0-rc2/client/index.esp ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.0.0-rc2/css" ; \
	cp src/paks/esp-html-mvc/css/app.less $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.0.0-rc2/css/app.less ; \
	cp src/paks/esp-html-mvc/css/theme.less $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.0.0-rc2/css/theme.less ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.0.0-rc2/generate" ; \
	cp src/paks/esp-html-mvc/generate/appweb.conf $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.0.0-rc2/generate/appweb.conf ; \
	cp src/paks/esp-html-mvc/generate/controller.c $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.0.0-rc2/generate/controller.c ; \
	cp src/paks/esp-html-mvc/generate/controllerSingleton.c $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.0.0-rc2/generate/controllerSingleton.c ; \
	cp src/paks/esp-html-mvc/generate/edit.esp $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.0.0-rc2/generate/edit.esp ; \
	cp src/paks/esp-html-mvc/generate/list.esp $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.0.0-rc2/generate/list.esp ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.0.0-rc2/layouts" ; \
	cp src/paks/esp-html-mvc/layouts/default.esp $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.0.0-rc2/layouts/default.esp ; \
	cp src/paks/esp-html-mvc/LICENSE.md $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.0.0-rc2/LICENSE.md ; \
	cp src/paks/esp-html-mvc/package.json $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.0.0-rc2/package.json ; \
	cp src/paks/esp-html-mvc/README.md $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.0.0-rc2/README.md ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-mvc/5.0.0-rc2" ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-mvc/5.0.0-rc2/generate" ; \
	cp src/paks/esp-mvc/generate/appweb.conf $(ME_VAPP_PREFIX)/esp/esp-mvc/5.0.0-rc2/generate/appweb.conf ; \
	cp src/paks/esp-mvc/generate/controller.c $(ME_VAPP_PREFIX)/esp/esp-mvc/5.0.0-rc2/generate/controller.c ; \
	cp src/paks/esp-mvc/generate/migration.c $(ME_VAPP_PREFIX)/esp/esp-mvc/5.0.0-rc2/generate/migration.c ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-mvc/5.0.0-rc2/generate/src" ; \
	cp src/paks/esp-mvc/generate/src/app.c $(ME_VAPP_PREFIX)/esp/esp-mvc/5.0.0-rc2/generate/src/app.c ; \
	cp src/paks/esp-mvc/LICENSE.md $(ME_VAPP_PREFIX)/esp/esp-mvc/5.0.0-rc2/LICENSE.md ; \
	cp src/paks/esp-mvc/package.json $(ME_VAPP_PREFIX)/esp/esp-mvc/5.0.0-rc2/package.json ; \
	cp src/paks/esp-mvc/README.md $(ME_VAPP_PREFIX)/esp/esp-mvc/5.0.0-rc2/README.md ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-server/5.0.0-rc2" ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-server/5.0.0-rc2/generate" ; \
	cp src/paks/esp-server/generate/appweb.conf $(ME_VAPP_PREFIX)/esp/esp-server/5.0.0-rc2/generate/appweb.conf ; \
	cp src/paks/esp-server/LICENSE.md $(ME_VAPP_PREFIX)/esp/esp-server/5.0.0-rc2/LICENSE.md ; \
	cp src/paks/esp-server/package.json $(ME_VAPP_PREFIX)/esp/esp-server/5.0.0-rc2/package.json ; \
	cp src/paks/esp-server/README.md $(ME_VAPP_PREFIX)/esp/esp-server/5.0.0-rc2/README.md ; \
	cp $(CONFIG)/bin/esp.conf $(ME_VAPP_PREFIX)/bin/esp.conf ; \
	mkdir -p "$(ME_VAPP_PREFIX)/doc/man/man1" ; \
	cp doc/man/esp.1 $(ME_VAPP_PREFIX)/doc/man/man1/esp.1 ; \
	mkdir -p "$(ME_MAN_PREFIX)/man1" ; \
	rm -f "$(ME_MAN_PREFIX)/man1/esp.1" ; \
	ln -s "$(ME_VAPP_PREFIX)/doc/man/man1/esp.1" "$(ME_MAN_PREFIX)/man1/esp.1" ; \
	mkdir -p "$(ME_VAPP_PREFIX)/inc" ; \
	cp $(CONFIG)/inc/me.h $(ME_VAPP_PREFIX)/inc/me.h ; \
	mkdir -p "$(ME_INC_PREFIX)/esp" ; \
	rm -f "$(ME_INC_PREFIX)/esp/me.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/me.h" "$(ME_INC_PREFIX)/esp/me.h" ; \
	cp src/esp.h $(ME_VAPP_PREFIX)/inc/esp.h ; \
	rm -f "$(ME_INC_PREFIX)/esp/esp.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/esp.h" "$(ME_INC_PREFIX)/esp/esp.h" ; \
	cp src/edi.h $(ME_VAPP_PREFIX)/inc/edi.h ; \
	rm -f "$(ME_INC_PREFIX)/esp/edi.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/edi.h" "$(ME_INC_PREFIX)/esp/edi.h" ; \
	cp src/paks/osdep/osdep.h $(ME_VAPP_PREFIX)/inc/osdep.h ; \
	rm -f "$(ME_INC_PREFIX)/esp/osdep.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/osdep.h" "$(ME_INC_PREFIX)/esp/osdep.h" ; \
	cp src/paks/appweb/appweb.h $(ME_VAPP_PREFIX)/inc/appweb.h ; \
	rm -f "$(ME_INC_PREFIX)/esp/appweb.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/appweb.h" "$(ME_INC_PREFIX)/esp/appweb.h" ; \
	cp src/paks/est/est.h $(ME_VAPP_PREFIX)/inc/est.h ; \
	rm -f "$(ME_INC_PREFIX)/esp/est.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/est.h" "$(ME_INC_PREFIX)/esp/est.h" ; \
	cp src/paks/http/http.h $(ME_VAPP_PREFIX)/inc/http.h ; \
	rm -f "$(ME_INC_PREFIX)/esp/http.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/http.h" "$(ME_INC_PREFIX)/esp/http.h" ; \
	cp src/paks/mpr/mpr.h $(ME_VAPP_PREFIX)/inc/mpr.h ; \
	rm -f "$(ME_INC_PREFIX)/esp/mpr.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/mpr.h" "$(ME_INC_PREFIX)/esp/mpr.h" ; \
	cp src/paks/pcre/pcre.h $(ME_VAPP_PREFIX)/inc/pcre.h ; \
	rm -f "$(ME_INC_PREFIX)/esp/pcre.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/pcre.h" "$(ME_INC_PREFIX)/esp/pcre.h" ; \
	cp src/paks/sqlite/sqlite3.h $(ME_VAPP_PREFIX)/inc/sqlite3.h ; \
	rm -f "$(ME_INC_PREFIX)/esp/sqlite3.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/sqlite3.h" "$(ME_INC_PREFIX)/esp/sqlite3.h" ; \
	)

#
#   start
#
start: $(DEPS_47)

#
#   install
#
DEPS_48 += stop
DEPS_48 += installBinary
DEPS_48 += start

install: $(DEPS_48)

#
#   uninstall
#
DEPS_49 += stop

uninstall: $(DEPS_49)
	( \
	cd .; \
	rm -fr "$(ME_VAPP_PREFIX)" ; \
	rm -f "$(ME_APP_PREFIX)/latest" ; \
	rmdir -p "$(ME_APP_PREFIX)" 2>/dev/null ; true ; \
	)

#
#   version
#
version: $(DEPS_50)
	echo 5.0.0-rc2

