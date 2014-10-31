#
#   esp-macosx-default.mk -- Makefile to build Embedthis ESP for macosx
#

NAME                  := esp
VERSION               := 5.2.0
PROFILE               ?= default
ARCH                  ?= $(shell uname -m | sed 's/i.86/x86/;s/x86_64/x64/;s/arm.*/arm/;s/mips.*/mips/')
CC_ARCH               ?= $(shell echo $(ARCH) | sed 's/x86/i686/;s/x64/x86_64/')
OS                    ?= macosx
CC                    ?= clang
CONFIG                ?= $(OS)-$(ARCH)-$(PROFILE)
BUILD                 ?= build/$(CONFIG)
LBIN                  ?= $(BUILD)/bin
PATH                  := $(LBIN):$(PATH)

ME_COM_APPWEB         ?= 1
ME_COM_CGI            ?= 0
ME_COM_DIR            ?= 0
ME_COM_EST            ?= 1
ME_COM_HTTP           ?= 1
ME_COM_MDB            ?= 1
ME_COM_OPENSSL        ?= 0
ME_COM_OSDEP          ?= 1
ME_COM_PCRE           ?= 1
ME_COM_SQLITE         ?= 1
ME_COM_SSL            ?= 1
ME_COM_VXWORKS        ?= 0
ME_COM_WINSDK         ?= 1

ifeq ($(ME_COM_EST),1)
    ME_COM_SSL := 1
endif
ifeq ($(ME_COM_OPENSSL),1)
    ME_COM_SSL := 1
endif

CFLAGS                += -g -w
DFLAGS                +=  $(patsubst %,-D%,$(filter ME_%,$(MAKEFLAGS))) -DME_COM_APPWEB=$(ME_COM_APPWEB) -DME_COM_CGI=$(ME_COM_CGI) -DME_COM_DIR=$(ME_COM_DIR) -DME_COM_EST=$(ME_COM_EST) -DME_COM_HTTP=$(ME_COM_HTTP) -DME_COM_MDB=$(ME_COM_MDB) -DME_COM_OPENSSL=$(ME_COM_OPENSSL) -DME_COM_OSDEP=$(ME_COM_OSDEP) -DME_COM_PCRE=$(ME_COM_PCRE) -DME_COM_SQLITE=$(ME_COM_SQLITE) -DME_COM_SSL=$(ME_COM_SSL) -DME_COM_VXWORKS=$(ME_COM_VXWORKS) -DME_COM_WINSDK=$(ME_COM_WINSDK) 
IFLAGS                += "-I$(BUILD)/inc"
LDFLAGS               += '-Wl,-rpath,@executable_path/' '-Wl,-rpath,@loader_path/'
LIBPATHS              += -L$(BUILD)/bin
LIBS                  += -ldl -lpthread -lm

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
ME_WEB_PREFIX         ?= $(ME_ROOT_PREFIX)/var/www/$(NAME)
ME_LOG_PREFIX         ?= $(ME_ROOT_PREFIX)/var/log/$(NAME)
ME_SPOOL_PREFIX       ?= $(ME_ROOT_PREFIX)/var/spool/$(NAME)
ME_CACHE_PREFIX       ?= $(ME_ROOT_PREFIX)/var/spool/$(NAME)/cache
ME_SRC_PREFIX         ?= $(ME_ROOT_PREFIX)$(NAME)-$(VERSION)


TARGETS               += $(BUILD)/esp
TARGETS               += $(BUILD)/bin/esp.conf
TARGETS               += $(BUILD)/bin/esp
TARGETS               += $(BUILD)/bin/ca.crt
ifeq ($(ME_COM_EST),1)
    TARGETS           += $(BUILD)/bin/libest.dylib
endif
TARGETS               += $(BUILD)/bin/libmprssl.dylib
TARGETS               += $(BUILD)/bin/espman

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
	@[ ! -x $(BUILD)/bin ] && mkdir -p $(BUILD)/bin; true
	@[ ! -x $(BUILD)/inc ] && mkdir -p $(BUILD)/inc; true
	@[ ! -x $(BUILD)/obj ] && mkdir -p $(BUILD)/obj; true
	@[ ! -f $(BUILD)/inc/me.h ] && cp projects/esp-macosx-default-me.h $(BUILD)/inc/me.h ; true
	@if ! diff $(BUILD)/inc/me.h projects/esp-macosx-default-me.h >/dev/null ; then\
		cp projects/esp-macosx-default-me.h $(BUILD)/inc/me.h  ; \
	fi; true
	@if [ -f "$(BUILD)/.makeflags" ] ; then \
		if [ "$(MAKEFLAGS)" != "`cat $(BUILD)/.makeflags`" ] ; then \
			echo "   [Warning] Make flags have changed since the last build: "`cat $(BUILD)/.makeflags`"" ; \
		fi ; \
	fi
	@echo "$(MAKEFLAGS)" >$(BUILD)/.makeflags

clean:
	rm -f "$(BUILD)/obj/appwebLib.o"
	rm -f "$(BUILD)/obj/edi.o"
	rm -f "$(BUILD)/obj/esp.o"
	rm -f "$(BUILD)/obj/espAbbrev.o"
	rm -f "$(BUILD)/obj/espConfig.o"
	rm -f "$(BUILD)/obj/espFramework.o"
	rm -f "$(BUILD)/obj/espHandler.o"
	rm -f "$(BUILD)/obj/espHtml.o"
	rm -f "$(BUILD)/obj/espTemplate.o"
	rm -f "$(BUILD)/obj/estLib.o"
	rm -f "$(BUILD)/obj/httpLib.o"
	rm -f "$(BUILD)/obj/makerom.o"
	rm -f "$(BUILD)/obj/manager.o"
	rm -f "$(BUILD)/obj/mdb.o"
	rm -f "$(BUILD)/obj/mprLib.o"
	rm -f "$(BUILD)/obj/mprSsl.o"
	rm -f "$(BUILD)/obj/pcre.o"
	rm -f "$(BUILD)/obj/sdb.o"
	rm -f "$(BUILD)/obj/sqlite.o"
	rm -f "$(BUILD)/obj/sqlite3.o"
	rm -f "$(BUILD)/bin/esp.conf"
	rm -f "$(BUILD)/bin/esp"
	rm -f "$(BUILD)/bin/ca.crt"
	rm -f "$(BUILD)/bin/libappweb.dylib"
	rm -f "$(BUILD)/bin/libest.dylib"
	rm -f "$(BUILD)/bin/libhttp.dylib"
	rm -f "$(BUILD)/bin/libmod_esp.dylib"
	rm -f "$(BUILD)/bin/libmpr.dylib"
	rm -f "$(BUILD)/bin/libmprssl.dylib"
	rm -f "$(BUILD)/bin/libpcre.dylib"
	rm -f "$(BUILD)/bin/libsql.dylib"
	rm -f "$(BUILD)/bin/espman"

clobber: clean
	rm -fr ./$(BUILD)

#
#   me.h
#

$(BUILD)/inc/me.h: $(DEPS_1)

#
#   osdep.h
#
DEPS_2 += src/paks/osdep/osdep.h
DEPS_2 += $(BUILD)/inc/me.h

$(BUILD)/inc/osdep.h: $(DEPS_2)
	@echo '      [Copy] $(BUILD)/inc/osdep.h'
	mkdir -p "$(BUILD)/inc"
	cp src/paks/osdep/osdep.h $(BUILD)/inc/osdep.h

#
#   mpr.h
#
DEPS_3 += src/paks/mpr/mpr.h
DEPS_3 += $(BUILD)/inc/me.h
DEPS_3 += $(BUILD)/inc/osdep.h

$(BUILD)/inc/mpr.h: $(DEPS_3)
	@echo '      [Copy] $(BUILD)/inc/mpr.h'
	mkdir -p "$(BUILD)/inc"
	cp src/paks/mpr/mpr.h $(BUILD)/inc/mpr.h

#
#   http.h
#
DEPS_4 += src/paks/http/http.h
DEPS_4 += $(BUILD)/inc/mpr.h

$(BUILD)/inc/http.h: $(DEPS_4)
	@echo '      [Copy] $(BUILD)/inc/http.h'
	mkdir -p "$(BUILD)/inc"
	cp src/paks/http/http.h $(BUILD)/inc/http.h

#
#   appweb.h
#
DEPS_5 += src/paks/appweb/appweb.h
DEPS_5 += $(BUILD)/inc/osdep.h
DEPS_5 += $(BUILD)/inc/mpr.h
DEPS_5 += $(BUILD)/inc/http.h

$(BUILD)/inc/appweb.h: $(DEPS_5)
	@echo '      [Copy] $(BUILD)/inc/appweb.h'
	mkdir -p "$(BUILD)/inc"
	cp src/paks/appweb/appweb.h $(BUILD)/inc/appweb.h

#
#   edi.h
#
DEPS_6 += src/edi.h
DEPS_6 += $(BUILD)/inc/http.h

$(BUILD)/inc/edi.h: $(DEPS_6)
	@echo '      [Copy] $(BUILD)/inc/edi.h'
	mkdir -p "$(BUILD)/inc"
	cp src/edi.h $(BUILD)/inc/edi.h

#
#   esp.h
#
DEPS_7 += src/esp.h
DEPS_7 += $(BUILD)/inc/appweb.h
DEPS_7 += $(BUILD)/inc/edi.h

$(BUILD)/inc/esp.h: $(DEPS_7)
	@echo '      [Copy] $(BUILD)/inc/esp.h'
	mkdir -p "$(BUILD)/inc"
	cp src/esp.h $(BUILD)/inc/esp.h

#
#   est.h
#
DEPS_8 += src/paks/est/est.h
DEPS_8 += $(BUILD)/inc/me.h
DEPS_8 += $(BUILD)/inc/osdep.h

$(BUILD)/inc/est.h: $(DEPS_8)
	@echo '      [Copy] $(BUILD)/inc/est.h'
	mkdir -p "$(BUILD)/inc"
	cp src/paks/est/est.h $(BUILD)/inc/est.h

#
#   mdb.h
#
DEPS_9 += src/mdb.h
DEPS_9 += $(BUILD)/inc/http.h
DEPS_9 += $(BUILD)/inc/edi.h

$(BUILD)/inc/mdb.h: $(DEPS_9)
	@echo '      [Copy] $(BUILD)/inc/mdb.h'
	mkdir -p "$(BUILD)/inc"
	cp src/mdb.h $(BUILD)/inc/mdb.h

#
#   pcre.h
#
DEPS_10 += src/paks/pcre/pcre.h

$(BUILD)/inc/pcre.h: $(DEPS_10)
	@echo '      [Copy] $(BUILD)/inc/pcre.h'
	mkdir -p "$(BUILD)/inc"
	cp src/paks/pcre/pcre.h $(BUILD)/inc/pcre.h

#
#   sqlite3.h
#
DEPS_11 += src/paks/sqlite/sqlite3.h
DEPS_11 += $(BUILD)/inc/me.h

$(BUILD)/inc/sqlite3.h: $(DEPS_11)
	@echo '      [Copy] $(BUILD)/inc/sqlite3.h'
	mkdir -p "$(BUILD)/inc"
	cp src/paks/sqlite/sqlite3.h $(BUILD)/inc/sqlite3.h

#
#   appwebLib.o
#
DEPS_12 += $(BUILD)/inc/appweb.h
DEPS_12 += $(BUILD)/inc/pcre.h
DEPS_12 += $(BUILD)/inc/mpr.h

$(BUILD)/obj/appwebLib.o: \
    src/paks/appweb/appwebLib.c $(DEPS_12)
	@echo '   [Compile] $(BUILD)/obj/appwebLib.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/appwebLib.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/paks/appweb/appwebLib.c

#
#   edi.o
#
DEPS_13 += $(BUILD)/inc/edi.h
DEPS_13 += $(BUILD)/inc/pcre.h

$(BUILD)/obj/edi.o: \
    src/edi.c $(DEPS_13)
	@echo '   [Compile] $(BUILD)/obj/edi.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/edi.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/edi.c

#
#   esp.o
#
DEPS_14 += $(BUILD)/inc/esp.h

$(BUILD)/obj/esp.o: \
    src/esp.c $(DEPS_14)
	@echo '   [Compile] $(BUILD)/obj/esp.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/esp.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/esp.c

#
#   espAbbrev.o
#
DEPS_15 += $(BUILD)/inc/esp.h

$(BUILD)/obj/espAbbrev.o: \
    src/espAbbrev.c $(DEPS_15)
	@echo '   [Compile] $(BUILD)/obj/espAbbrev.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/espAbbrev.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/espAbbrev.c

#
#   espConfig.o
#
DEPS_16 += $(BUILD)/inc/esp.h

$(BUILD)/obj/espConfig.o: \
    src/espConfig.c $(DEPS_16)
	@echo '   [Compile] $(BUILD)/obj/espConfig.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/espConfig.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/espConfig.c

#
#   espFramework.o
#
DEPS_17 += $(BUILD)/inc/esp.h

$(BUILD)/obj/espFramework.o: \
    src/espFramework.c $(DEPS_17)
	@echo '   [Compile] $(BUILD)/obj/espFramework.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/espFramework.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/espFramework.c

#
#   espHandler.o
#
DEPS_18 += $(BUILD)/inc/esp.h

$(BUILD)/obj/espHandler.o: \
    src/espHandler.c $(DEPS_18)
	@echo '   [Compile] $(BUILD)/obj/espHandler.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/espHandler.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/espHandler.c

#
#   espHtml.o
#
DEPS_19 += $(BUILD)/inc/esp.h
DEPS_19 += $(BUILD)/inc/edi.h

$(BUILD)/obj/espHtml.o: \
    src/espHtml.c $(DEPS_19)
	@echo '   [Compile] $(BUILD)/obj/espHtml.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/espHtml.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/espHtml.c

#
#   espTemplate.o
#
DEPS_20 += $(BUILD)/inc/esp.h

$(BUILD)/obj/espTemplate.o: \
    src/espTemplate.c $(DEPS_20)
	@echo '   [Compile] $(BUILD)/obj/espTemplate.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/espTemplate.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/espTemplate.c

#
#   estLib.o
#
DEPS_21 += $(BUILD)/inc/est.h

$(BUILD)/obj/estLib.o: \
    src/paks/est/estLib.c $(DEPS_21)
	@echo '   [Compile] $(BUILD)/obj/estLib.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/estLib.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/paks/est/estLib.c

#
#   httpLib.o
#
DEPS_22 += $(BUILD)/inc/http.h

$(BUILD)/obj/httpLib.o: \
    src/paks/http/httpLib.c $(DEPS_22)
	@echo '   [Compile] $(BUILD)/obj/httpLib.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/httpLib.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/paks/http/httpLib.c

#
#   makerom.o
#
DEPS_23 += $(BUILD)/inc/mpr.h

$(BUILD)/obj/makerom.o: \
    src/paks/mpr/makerom.c $(DEPS_23)
	@echo '   [Compile] $(BUILD)/obj/makerom.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/makerom.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/paks/mpr/makerom.c

#
#   manager.o
#
DEPS_24 += $(BUILD)/inc/mpr.h

$(BUILD)/obj/manager.o: \
    src/paks/mpr/manager.c $(DEPS_24)
	@echo '   [Compile] $(BUILD)/obj/manager.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/manager.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/paks/mpr/manager.c

#
#   mdb.o
#
DEPS_25 += $(BUILD)/inc/http.h
DEPS_25 += $(BUILD)/inc/edi.h
DEPS_25 += $(BUILD)/inc/mdb.h
DEPS_25 += $(BUILD)/inc/pcre.h

$(BUILD)/obj/mdb.o: \
    src/mdb.c $(DEPS_25)
	@echo '   [Compile] $(BUILD)/obj/mdb.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/mdb.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/mdb.c

#
#   mprLib.o
#
DEPS_26 += $(BUILD)/inc/mpr.h

$(BUILD)/obj/mprLib.o: \
    src/paks/mpr/mprLib.c $(DEPS_26)
	@echo '   [Compile] $(BUILD)/obj/mprLib.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/mprLib.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/paks/mpr/mprLib.c

#
#   mprSsl.o
#
DEPS_27 += $(BUILD)/inc/mpr.h

$(BUILD)/obj/mprSsl.o: \
    src/paks/mpr/mprSsl.c $(DEPS_27)
	@echo '   [Compile] $(BUILD)/obj/mprSsl.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/mprSsl.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) "-I$(ME_COM_OPENSSL_PATH)/include" src/paks/mpr/mprSsl.c

#
#   pcre.o
#
DEPS_28 += $(BUILD)/inc/me.h
DEPS_28 += $(BUILD)/inc/pcre.h

$(BUILD)/obj/pcre.o: \
    src/paks/pcre/pcre.c $(DEPS_28)
	@echo '   [Compile] $(BUILD)/obj/pcre.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/pcre.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/paks/pcre/pcre.c

#
#   sdb.o
#
DEPS_29 += $(BUILD)/inc/http.h
DEPS_29 += $(BUILD)/inc/edi.h

$(BUILD)/obj/sdb.o: \
    src/sdb.c $(DEPS_29)
	@echo '   [Compile] $(BUILD)/obj/sdb.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/sdb.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/sdb.c

#
#   sqlite.o
#
DEPS_30 += $(BUILD)/inc/me.h
DEPS_30 += $(BUILD)/inc/sqlite3.h

$(BUILD)/obj/sqlite.o: \
    src/paks/sqlite/sqlite.c $(DEPS_30)
	@echo '   [Compile] $(BUILD)/obj/sqlite.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/sqlite.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/paks/sqlite/sqlite.c

#
#   sqlite3.o
#
DEPS_31 += $(BUILD)/inc/me.h
DEPS_31 += $(BUILD)/inc/sqlite3.h

$(BUILD)/obj/sqlite3.o: \
    src/paks/sqlite/sqlite3.c $(DEPS_31)
	@echo '   [Compile] $(BUILD)/obj/sqlite3.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/sqlite3.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/paks/sqlite/sqlite3.c

#
#   esp-paks
#
DEPS_32 += src/paks/esp-html-mvc/client/assets/favicon.ico
DEPS_32 += src/paks/esp-html-mvc/client/css/all.css
DEPS_32 += src/paks/esp-html-mvc/client/css/all.less
DEPS_32 += src/paks/esp-html-mvc/client/index.esp
DEPS_32 += src/paks/esp-html-mvc/css/app.less
DEPS_32 += src/paks/esp-html-mvc/css/theme.less
DEPS_32 += src/paks/esp-html-mvc/generate/appweb.conf
DEPS_32 += src/paks/esp-html-mvc/generate/controller.c
DEPS_32 += src/paks/esp-html-mvc/generate/controllerSingleton.c
DEPS_32 += src/paks/esp-html-mvc/generate/edit.esp
DEPS_32 += src/paks/esp-html-mvc/generate/list.esp
DEPS_32 += src/paks/esp-html-mvc/layouts/default.esp
DEPS_32 += src/paks/esp-html-mvc/LICENSE.md
DEPS_32 += src/paks/esp-html-mvc/package.json
DEPS_32 += src/paks/esp-html-mvc/README.md
DEPS_32 += src/paks/esp-mvc/generate/appweb.conf
DEPS_32 += src/paks/esp-mvc/generate/controller.c
DEPS_32 += src/paks/esp-mvc/generate/migration.c
DEPS_32 += src/paks/esp-mvc/generate/src/app.c
DEPS_32 += src/paks/esp-mvc/LICENSE.md
DEPS_32 += src/paks/esp-mvc/package.json
DEPS_32 += src/paks/esp-mvc/README.md
DEPS_32 += src/paks/esp-server/generate/appweb.conf
DEPS_32 += src/paks/esp-server/LICENSE.md
DEPS_32 += src/paks/esp-server/package.json
DEPS_32 += src/paks/esp-server/README.md

$(BUILD)/esp: $(DEPS_32)
	( \
	cd src/paks; \
	echo '      [Copy] src/paks/esp-*' ; \
	mkdir -p "../../$(BUILD)/esp/esp-html-mvc/5.2.0" ; \
	mkdir -p "../../$(BUILD)/esp/esp-html-mvc/5.2.0/client" ; \
	mkdir -p "../../$(BUILD)/esp/esp-html-mvc/5.2.0/client/assets" ; \
	cp esp-html-mvc/client/assets/favicon.ico ../../$(BUILD)/esp/esp-html-mvc/5.2.0/client/assets/favicon.ico ; \
	mkdir -p "../../$(BUILD)/esp/esp-html-mvc/5.2.0/client/css" ; \
	cp esp-html-mvc/client/css/all.css ../../$(BUILD)/esp/esp-html-mvc/5.2.0/client/css/all.css ; \
	cp esp-html-mvc/client/css/all.less ../../$(BUILD)/esp/esp-html-mvc/5.2.0/client/css/all.less ; \
	cp esp-html-mvc/client/index.esp ../../$(BUILD)/esp/esp-html-mvc/5.2.0/client/index.esp ; \
	mkdir -p "../../$(BUILD)/esp/esp-html-mvc/5.2.0/css" ; \
	cp esp-html-mvc/css/app.less ../../$(BUILD)/esp/esp-html-mvc/5.2.0/css/app.less ; \
	cp esp-html-mvc/css/theme.less ../../$(BUILD)/esp/esp-html-mvc/5.2.0/css/theme.less ; \
	mkdir -p "../../$(BUILD)/esp/esp-html-mvc/5.2.0/generate" ; \
	cp esp-html-mvc/generate/appweb.conf ../../$(BUILD)/esp/esp-html-mvc/5.2.0/generate/appweb.conf ; \
	cp esp-html-mvc/generate/controller.c ../../$(BUILD)/esp/esp-html-mvc/5.2.0/generate/controller.c ; \
	cp esp-html-mvc/generate/controllerSingleton.c ../../$(BUILD)/esp/esp-html-mvc/5.2.0/generate/controllerSingleton.c ; \
	cp esp-html-mvc/generate/edit.esp ../../$(BUILD)/esp/esp-html-mvc/5.2.0/generate/edit.esp ; \
	cp esp-html-mvc/generate/list.esp ../../$(BUILD)/esp/esp-html-mvc/5.2.0/generate/list.esp ; \
	mkdir -p "../../$(BUILD)/esp/esp-html-mvc/5.2.0/layouts" ; \
	cp esp-html-mvc/layouts/default.esp ../../$(BUILD)/esp/esp-html-mvc/5.2.0/layouts/default.esp ; \
	cp esp-html-mvc/LICENSE.md ../../$(BUILD)/esp/esp-html-mvc/5.2.0/LICENSE.md ; \
	cp esp-html-mvc/package.json ../../$(BUILD)/esp/esp-html-mvc/5.2.0/package.json ; \
	cp esp-html-mvc/README.md ../../$(BUILD)/esp/esp-html-mvc/5.2.0/README.md ; \
	mkdir -p "../../$(BUILD)/esp/esp-mvc/5.2.0" ; \
	mkdir -p "../../$(BUILD)/esp/esp-mvc/5.2.0/generate" ; \
	cp esp-mvc/generate/appweb.conf ../../$(BUILD)/esp/esp-mvc/5.2.0/generate/appweb.conf ; \
	cp esp-mvc/generate/controller.c ../../$(BUILD)/esp/esp-mvc/5.2.0/generate/controller.c ; \
	cp esp-mvc/generate/migration.c ../../$(BUILD)/esp/esp-mvc/5.2.0/generate/migration.c ; \
	mkdir -p "../../$(BUILD)/esp/esp-mvc/5.2.0/generate/src" ; \
	cp esp-mvc/generate/src/app.c ../../$(BUILD)/esp/esp-mvc/5.2.0/generate/src/app.c ; \
	cp esp-mvc/LICENSE.md ../../$(BUILD)/esp/esp-mvc/5.2.0/LICENSE.md ; \
	cp esp-mvc/package.json ../../$(BUILD)/esp/esp-mvc/5.2.0/package.json ; \
	cp esp-mvc/README.md ../../$(BUILD)/esp/esp-mvc/5.2.0/README.md ; \
	mkdir -p "../../$(BUILD)/esp/esp-server/5.2.0" ; \
	mkdir -p "../../$(BUILD)/esp/esp-server/5.2.0/generate" ; \
	cp esp-server/generate/appweb.conf ../../$(BUILD)/esp/esp-server/5.2.0/generate/appweb.conf ; \
	cp esp-server/LICENSE.md ../../$(BUILD)/esp/esp-server/5.2.0/LICENSE.md ; \
	cp esp-server/package.json ../../$(BUILD)/esp/esp-server/5.2.0/package.json ; \
	cp esp-server/README.md ../../$(BUILD)/esp/esp-server/5.2.0/README.md ; \
	)

#
#   esp.conf
#
DEPS_33 += src/esp.conf

$(BUILD)/bin/esp.conf: $(DEPS_33)
	@echo '      [Copy] $(BUILD)/bin/esp.conf'
	mkdir -p "$(BUILD)/bin"
	cp src/esp.conf $(BUILD)/bin/esp.conf

#
#   libmpr
#
DEPS_34 += $(BUILD)/inc/osdep.h
DEPS_34 += $(BUILD)/inc/mpr.h
DEPS_34 += $(BUILD)/obj/mprLib.o

$(BUILD)/bin/libmpr.dylib: $(DEPS_34)
	@echo '      [Link] $(BUILD)/bin/libmpr.dylib'
	$(CC) -dynamiclib -o $(BUILD)/bin/libmpr.dylib -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) -install_name @rpath/libmpr.dylib -compatibility_version 5.2 -current_version 5.2 "$(BUILD)/obj/mprLib.o" $(LIBS) 

ifeq ($(ME_COM_PCRE),1)
#
#   libpcre
#
DEPS_35 += $(BUILD)/inc/pcre.h
DEPS_35 += $(BUILD)/obj/pcre.o

$(BUILD)/bin/libpcre.dylib: $(DEPS_35)
	@echo '      [Link] $(BUILD)/bin/libpcre.dylib'
	$(CC) -dynamiclib -o $(BUILD)/bin/libpcre.dylib -arch $(CC_ARCH) $(LDFLAGS) -compatibility_version 5.2 -current_version 5.2 $(LIBPATHS) -install_name @rpath/libpcre.dylib -compatibility_version 5.2 -current_version 5.2 "$(BUILD)/obj/pcre.o" $(LIBS) 
endif

ifeq ($(ME_COM_HTTP),1)
#
#   libhttp
#
DEPS_36 += $(BUILD)/bin/libmpr.dylib
ifeq ($(ME_COM_PCRE),1)
    DEPS_36 += $(BUILD)/bin/libpcre.dylib
endif
DEPS_36 += $(BUILD)/inc/http.h
DEPS_36 += $(BUILD)/obj/httpLib.o

LIBS_36 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_36 += -lpcre
endif

$(BUILD)/bin/libhttp.dylib: $(DEPS_36)
	@echo '      [Link] $(BUILD)/bin/libhttp.dylib'
	$(CC) -dynamiclib -o $(BUILD)/bin/libhttp.dylib -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) -install_name @rpath/libhttp.dylib -compatibility_version 5.2 -current_version 5.2 "$(BUILD)/obj/httpLib.o" $(LIBPATHS_36) $(LIBS_36) $(LIBS_36) $(LIBS) 
endif

ifeq ($(ME_COM_APPWEB),1)
#
#   libappweb
#
ifeq ($(ME_COM_HTTP),1)
    DEPS_37 += $(BUILD)/bin/libhttp.dylib
endif
ifeq ($(ME_COM_PCRE),1)
    DEPS_37 += $(BUILD)/bin/libpcre.dylib
endif
DEPS_37 += $(BUILD)/bin/libmpr.dylib
DEPS_37 += $(BUILD)/inc/appweb.h
DEPS_37 += $(BUILD)/obj/appwebLib.o

ifeq ($(ME_COM_HTTP),1)
    LIBS_37 += -lhttp
endif
LIBS_37 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_37 += -lpcre
endif

$(BUILD)/bin/libappweb.dylib: $(DEPS_37)
	@echo '      [Link] $(BUILD)/bin/libappweb.dylib'
	$(CC) -dynamiclib -o $(BUILD)/bin/libappweb.dylib -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) -install_name @rpath/libappweb.dylib -compatibility_version 5.2 -current_version 5.2 "$(BUILD)/obj/appwebLib.o" $(LIBPATHS_37) $(LIBS_37) $(LIBS_37) $(LIBS) 
endif

ifeq ($(ME_COM_SQLITE),1)
#
#   libsql
#
DEPS_38 += $(BUILD)/inc/sqlite3.h
DEPS_38 += $(BUILD)/obj/sqlite3.o

$(BUILD)/bin/libsql.dylib: $(DEPS_38)
	@echo '      [Link] $(BUILD)/bin/libsql.dylib'
	$(CC) -dynamiclib -o $(BUILD)/bin/libsql.dylib -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) -install_name @rpath/libsql.dylib -compatibility_version 5.2 -current_version 5.2 "$(BUILD)/obj/sqlite3.o" $(LIBS) 
endif

#
#   libmod_esp
#
ifeq ($(ME_COM_APPWEB),1)
    DEPS_39 += $(BUILD)/bin/libappweb.dylib
endif
ifeq ($(ME_COM_SQLITE),1)
    DEPS_39 += $(BUILD)/bin/libsql.dylib
endif
DEPS_39 += $(BUILD)/inc/edi.h
DEPS_39 += $(BUILD)/inc/esp.h
DEPS_39 += $(BUILD)/inc/mdb.h
DEPS_39 += $(BUILD)/obj/edi.o
DEPS_39 += $(BUILD)/obj/espAbbrev.o
DEPS_39 += $(BUILD)/obj/espConfig.o
DEPS_39 += $(BUILD)/obj/espFramework.o
DEPS_39 += $(BUILD)/obj/espHandler.o
DEPS_39 += $(BUILD)/obj/espHtml.o
DEPS_39 += $(BUILD)/obj/espTemplate.o
DEPS_39 += $(BUILD)/obj/mdb.o
DEPS_39 += $(BUILD)/obj/sdb.o

ifeq ($(ME_COM_APPWEB),1)
    LIBS_39 += -lappweb
endif
ifeq ($(ME_COM_HTTP),1)
    LIBS_39 += -lhttp
endif
LIBS_39 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_39 += -lpcre
endif
ifeq ($(ME_COM_SQLITE),1)
    LIBS_39 += -lsql
endif

$(BUILD)/bin/libmod_esp.dylib: $(DEPS_39)
	@echo '      [Link] $(BUILD)/bin/libmod_esp.dylib'
	$(CC) -dynamiclib -o $(BUILD)/bin/libmod_esp.dylib -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) -install_name @rpath/libmod_esp.dylib -compatibility_version 5.2 -current_version 5.2 "$(BUILD)/obj/edi.o" "$(BUILD)/obj/espAbbrev.o" "$(BUILD)/obj/espConfig.o" "$(BUILD)/obj/espFramework.o" "$(BUILD)/obj/espHandler.o" "$(BUILD)/obj/espHtml.o" "$(BUILD)/obj/espTemplate.o" "$(BUILD)/obj/mdb.o" "$(BUILD)/obj/sdb.o" $(LIBPATHS_39) $(LIBS_39) $(LIBS_39) $(LIBS) 

#
#   espcmd
#
ifeq ($(ME_COM_APPWEB),1)
    DEPS_40 += $(BUILD)/bin/libappweb.dylib
endif
ifeq ($(ME_COM_SQLITE),1)
    DEPS_40 += $(BUILD)/bin/libsql.dylib
endif
DEPS_40 += $(BUILD)/bin/libmod_esp.dylib
DEPS_40 += $(BUILD)/obj/esp.o

ifeq ($(ME_COM_APPWEB),1)
    LIBS_40 += -lappweb
endif
ifeq ($(ME_COM_HTTP),1)
    LIBS_40 += -lhttp
endif
LIBS_40 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_40 += -lpcre
endif
ifeq ($(ME_COM_SQLITE),1)
    LIBS_40 += -lsql
endif
LIBS_40 += -lmod_esp

$(BUILD)/bin/esp: $(DEPS_40)
	@echo '      [Link] $(BUILD)/bin/esp'
	$(CC) -o $(BUILD)/bin/esp -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/esp.o" $(LIBPATHS_40) $(LIBS_40) $(LIBS_40) $(LIBS) 

#
#   http-ca-crt
#
DEPS_41 += src/paks/http/ca.crt

$(BUILD)/bin/ca.crt: $(DEPS_41)
	@echo '      [Copy] $(BUILD)/bin/ca.crt'
	mkdir -p "$(BUILD)/bin"
	cp src/paks/http/ca.crt $(BUILD)/bin/ca.crt

ifeq ($(ME_COM_EST),1)
#
#   libest
#
DEPS_42 += $(BUILD)/inc/osdep.h
DEPS_42 += $(BUILD)/inc/est.h
DEPS_42 += $(BUILD)/obj/estLib.o

$(BUILD)/bin/libest.dylib: $(DEPS_42)
	@echo '      [Link] $(BUILD)/bin/libest.dylib'
	$(CC) -dynamiclib -o $(BUILD)/bin/libest.dylib -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) -install_name @rpath/libest.dylib -compatibility_version 5.2 -current_version 5.2 "$(BUILD)/obj/estLib.o" $(LIBS) 
endif

#
#   libmprssl
#
DEPS_43 += $(BUILD)/bin/libmpr.dylib
ifeq ($(ME_COM_EST),1)
    DEPS_43 += $(BUILD)/bin/libest.dylib
endif
DEPS_43 += $(BUILD)/obj/mprSsl.o

LIBS_43 += -lmpr
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_43 += -lssl
    LIBPATHS_43 += -L$(ME_COM_OPENSSL_PATH)
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_43 += -lcrypto
    LIBPATHS_43 += -L$(ME_COM_OPENSSL_PATH)
endif
ifeq ($(ME_COM_EST),1)
    LIBS_43 += -lest
endif

$(BUILD)/bin/libmprssl.dylib: $(DEPS_43)
	@echo '      [Link] $(BUILD)/bin/libmprssl.dylib'
	$(CC) -dynamiclib -o $(BUILD)/bin/libmprssl.dylib -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS)  -install_name @rpath/libmprssl.dylib -compatibility_version 5.2 -current_version 5.2 "$(BUILD)/obj/mprSsl.o" $(LIBPATHS_43) $(LIBS_43) $(LIBS_43) $(LIBS) 

#
#   manager
#
DEPS_44 += $(BUILD)/bin/libmpr.dylib
DEPS_44 += $(BUILD)/obj/manager.o

LIBS_44 += -lmpr

$(BUILD)/bin/espman: $(DEPS_44)
	@echo '      [Link] $(BUILD)/bin/espman'
	$(CC) -o $(BUILD)/bin/espman -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/manager.o" $(LIBPATHS_44) $(LIBS_44) $(LIBS_44) $(LIBS) 

#
#   stop
#

stop: $(DEPS_45)

#
#   installBinary
#

installBinary: $(DEPS_46)
	mkdir -p "$(ME_APP_PREFIX)" ; \
	rm -f "$(ME_APP_PREFIX)/latest" ; \
	ln -s "5.2.0" "$(ME_APP_PREFIX)/latest" ; \
	mkdir -p "$(ME_VAPP_PREFIX)/bin" ; \
	cp $(BUILD)/bin/esp $(ME_VAPP_PREFIX)/bin/esp ; \
	mkdir -p "$(ME_BIN_PREFIX)" ; \
	rm -f "$(ME_BIN_PREFIX)/esp" ; \
	ln -s "$(ME_VAPP_PREFIX)/bin/esp" "$(ME_BIN_PREFIX)/esp" ; \
	mkdir -p "$(ME_VAPP_PREFIX)/bin" ; \
	cp $(BUILD)/bin/espman $(ME_VAPP_PREFIX)/bin/espman ; \
	mkdir -p "$(ME_BIN_PREFIX)" ; \
	rm -f "$(ME_BIN_PREFIX)/espman" ; \
	ln -s "$(ME_VAPP_PREFIX)/bin/espman" "$(ME_BIN_PREFIX)/espman" ; \
	if [ "$(ME_COM_OPENSSL)" = 1 ]; then true ; \
	mkdir -p "$(ME_VAPP_PREFIX)/bin" ; \
	cp $(BUILD)/bin/libssl*.dylib* $(ME_VAPP_PREFIX)/bin/libssl*.dylib* ; \
	cp $(BUILD)/bin/libcrypto*.dylib* $(ME_VAPP_PREFIX)/bin/libcrypto*.dylib* ; \
	fi ; \
	mkdir -p "$(ME_VAPP_PREFIX)/bin" ; \
	cp $(BUILD)/bin/ca.crt $(ME_VAPP_PREFIX)/bin/ca.crt ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.2.0" ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.2.0/client" ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.2.0/client/assets" ; \
	cp ./src/paks/esp-html-mvc/client/assets/favicon.ico $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.2.0/client/assets/favicon.ico ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.2.0/client/css" ; \
	cp ./src/paks/esp-html-mvc/client/css/all.css $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.2.0/client/css/all.css ; \
	cp ./src/paks/esp-html-mvc/client/css/all.less $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.2.0/client/css/all.less ; \
	cp ./src/paks/esp-html-mvc/client/index.esp $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.2.0/client/index.esp ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.2.0/css" ; \
	cp ./src/paks/esp-html-mvc/css/app.less $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.2.0/css/app.less ; \
	cp ./src/paks/esp-html-mvc/css/theme.less $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.2.0/css/theme.less ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.2.0/generate" ; \
	cp ./src/paks/esp-html-mvc/generate/appweb.conf $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.2.0/generate/appweb.conf ; \
	cp ./src/paks/esp-html-mvc/generate/controller.c $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.2.0/generate/controller.c ; \
	cp ./src/paks/esp-html-mvc/generate/controllerSingleton.c $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.2.0/generate/controllerSingleton.c ; \
	cp ./src/paks/esp-html-mvc/generate/edit.esp $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.2.0/generate/edit.esp ; \
	cp ./src/paks/esp-html-mvc/generate/list.esp $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.2.0/generate/list.esp ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.2.0/layouts" ; \
	cp ./src/paks/esp-html-mvc/layouts/default.esp $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.2.0/layouts/default.esp ; \
	cp ./src/paks/esp-html-mvc/LICENSE.md $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.2.0/LICENSE.md ; \
	cp ./src/paks/esp-html-mvc/package.json $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.2.0/package.json ; \
	cp ./src/paks/esp-html-mvc/README.md $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.2.0/README.md ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-mvc/5.2.0" ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-mvc/5.2.0/generate" ; \
	cp ./src/paks/esp-mvc/generate/appweb.conf $(ME_VAPP_PREFIX)/esp/esp-mvc/5.2.0/generate/appweb.conf ; \
	cp ./src/paks/esp-mvc/generate/controller.c $(ME_VAPP_PREFIX)/esp/esp-mvc/5.2.0/generate/controller.c ; \
	cp ./src/paks/esp-mvc/generate/migration.c $(ME_VAPP_PREFIX)/esp/esp-mvc/5.2.0/generate/migration.c ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-mvc/5.2.0/generate/src" ; \
	cp ./src/paks/esp-mvc/generate/src/app.c $(ME_VAPP_PREFIX)/esp/esp-mvc/5.2.0/generate/src/app.c ; \
	cp ./src/paks/esp-mvc/LICENSE.md $(ME_VAPP_PREFIX)/esp/esp-mvc/5.2.0/LICENSE.md ; \
	cp ./src/paks/esp-mvc/package.json $(ME_VAPP_PREFIX)/esp/esp-mvc/5.2.0/package.json ; \
	cp ./src/paks/esp-mvc/README.md $(ME_VAPP_PREFIX)/esp/esp-mvc/5.2.0/README.md ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-server/5.2.0" ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-server/5.2.0/generate" ; \
	cp ./src/paks/esp-server/generate/appweb.conf $(ME_VAPP_PREFIX)/esp/esp-server/5.2.0/generate/appweb.conf ; \
	cp ./src/paks/esp-server/LICENSE.md $(ME_VAPP_PREFIX)/esp/esp-server/5.2.0/LICENSE.md ; \
	cp ./src/paks/esp-server/package.json $(ME_VAPP_PREFIX)/esp/esp-server/5.2.0/package.json ; \
	cp ./src/paks/esp-server/README.md $(ME_VAPP_PREFIX)/esp/esp-server/5.2.0/README.md ; \
	mkdir -p "$(ME_VAPP_PREFIX)/bin" ; \
	cp $(BUILD)/bin/esp.conf $(ME_VAPP_PREFIX)/bin/esp.conf ; \
	mkdir -p "$(ME_VAPP_PREFIX)/bin" ; \
	cp $(BUILD)/bin/libappweb.dylib $(ME_VAPP_PREFIX)/bin/libappweb.dylib ; \
	cp $(BUILD)/bin/libhttp.dylib $(ME_VAPP_PREFIX)/bin/libhttp.dylib ; \
	cp $(BUILD)/bin/libmpr.dylib $(ME_VAPP_PREFIX)/bin/libmpr.dylib ; \
	cp $(BUILD)/bin/libmprssl.dylib $(ME_VAPP_PREFIX)/bin/libmprssl.dylib ; \
	cp $(BUILD)/bin/libpcre.dylib $(ME_VAPP_PREFIX)/bin/libpcre.dylib ; \
	cp $(BUILD)/bin/libsql.dylib $(ME_VAPP_PREFIX)/bin/libsql.dylib ; \
	cp $(BUILD)/bin/libmod_esp.dylib $(ME_VAPP_PREFIX)/bin/libmod_esp.dylib ; \
	if [ "$(ME_COM_EST)" = 1 ]; then true ; \
	mkdir -p "$(ME_VAPP_PREFIX)/bin" ; \
	cp $(BUILD)/bin/libest.dylib $(ME_VAPP_PREFIX)/bin/libest.dylib ; \
	fi ; \
	mkdir -p "$(ME_VAPP_PREFIX)/inc" ; \
	cp $(BUILD)/inc/me.h $(ME_VAPP_PREFIX)/inc/me.h ; \
	mkdir -p "$(ME_INC_PREFIX)/esp" ; \
	rm -f "$(ME_INC_PREFIX)/esp/me.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/me.h" "$(ME_INC_PREFIX)/esp/me.h" ; \
	cp src/esp.h $(ME_VAPP_PREFIX)/inc/esp.h ; \
	mkdir -p "$(ME_INC_PREFIX)/esp" ; \
	rm -f "$(ME_INC_PREFIX)/esp/esp.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/esp.h" "$(ME_INC_PREFIX)/esp/esp.h" ; \
	cp src/edi.h $(ME_VAPP_PREFIX)/inc/edi.h ; \
	mkdir -p "$(ME_INC_PREFIX)/esp" ; \
	rm -f "$(ME_INC_PREFIX)/esp/edi.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/edi.h" "$(ME_INC_PREFIX)/esp/edi.h" ; \
	cp src/paks/osdep/osdep.h $(ME_VAPP_PREFIX)/inc/osdep.h ; \
	mkdir -p "$(ME_INC_PREFIX)/esp" ; \
	rm -f "$(ME_INC_PREFIX)/esp/osdep.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/osdep.h" "$(ME_INC_PREFIX)/esp/osdep.h" ; \
	cp src/paks/appweb/appweb.h $(ME_VAPP_PREFIX)/inc/appweb.h ; \
	mkdir -p "$(ME_INC_PREFIX)/esp" ; \
	rm -f "$(ME_INC_PREFIX)/esp/appweb.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/appweb.h" "$(ME_INC_PREFIX)/esp/appweb.h" ; \
	cp src/paks/est/est.h $(ME_VAPP_PREFIX)/inc/est.h ; \
	mkdir -p "$(ME_INC_PREFIX)/esp" ; \
	rm -f "$(ME_INC_PREFIX)/esp/est.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/est.h" "$(ME_INC_PREFIX)/esp/est.h" ; \
	cp src/paks/http/http.h $(ME_VAPP_PREFIX)/inc/http.h ; \
	mkdir -p "$(ME_INC_PREFIX)/esp" ; \
	rm -f "$(ME_INC_PREFIX)/esp/http.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/http.h" "$(ME_INC_PREFIX)/esp/http.h" ; \
	cp src/paks/mpr/mpr.h $(ME_VAPP_PREFIX)/inc/mpr.h ; \
	mkdir -p "$(ME_INC_PREFIX)/esp" ; \
	rm -f "$(ME_INC_PREFIX)/esp/mpr.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/mpr.h" "$(ME_INC_PREFIX)/esp/mpr.h" ; \
	cp src/paks/pcre/pcre.h $(ME_VAPP_PREFIX)/inc/pcre.h ; \
	mkdir -p "$(ME_INC_PREFIX)/esp" ; \
	rm -f "$(ME_INC_PREFIX)/esp/pcre.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/pcre.h" "$(ME_INC_PREFIX)/esp/pcre.h" ; \
	cp src/paks/sqlite/sqlite3.h $(ME_VAPP_PREFIX)/inc/sqlite3.h ; \
	mkdir -p "$(ME_INC_PREFIX)/esp" ; \
	rm -f "$(ME_INC_PREFIX)/esp/sqlite3.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/sqlite3.h" "$(ME_INC_PREFIX)/esp/sqlite3.h" ; \
	mkdir -p "$(ME_VAPP_PREFIX)/doc/man/man1" ; \
	cp doc/documents/man/esp.1 $(ME_VAPP_PREFIX)/doc/man/man1/esp.1 ; \
	mkdir -p "$(ME_MAN_PREFIX)/man1" ; \
	rm -f "$(ME_MAN_PREFIX)/man1/esp.1" ; \
	ln -s "$(ME_VAPP_PREFIX)/doc/man/man1/esp.1" "$(ME_MAN_PREFIX)/man1/esp.1"

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
	rm -fr "$(ME_VAPP_PREFIX)" ; \
	rm -f "$(ME_APP_PREFIX)/latest" ; \
	rmdir -p "$(ME_APP_PREFIX)" 2>/dev/null ; true

#
#   version
#

version: $(DEPS_50)
	echo 5.2.0

