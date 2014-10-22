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
TARGETS               += $(BUILD)/bin/makerom
TARGETS               += $(BUILD)/bin/espman
ifeq ($(ME_COM_SQLITE),1)
    TARGETS           += $(BUILD)/bin/sqlite
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
	rm -f "$(BUILD)/bin/makerom"
	rm -f "$(BUILD)/bin/espman"
	rm -f "$(BUILD)/bin/sqlite"

clobber: clean
	rm -fr ./$(BUILD)

#
#   appweb.h
#
DEPS_1 += src/paks/appweb/appweb.h

$(BUILD)/inc/appweb.h: $(DEPS_1)
	@echo '      [Copy] $(BUILD)/inc/appweb.h'
	mkdir -p "$(BUILD)/inc"
	cp src/paks/appweb/appweb.h $(BUILD)/inc/appweb.h

#
#   edi.h
#
DEPS_2 += src/edi.h

$(BUILD)/inc/edi.h: $(DEPS_2)
	@echo '      [Copy] $(BUILD)/inc/edi.h'
	mkdir -p "$(BUILD)/inc"
	cp src/edi.h $(BUILD)/inc/edi.h

#
#   esp.h
#
DEPS_3 += src/esp.h

$(BUILD)/inc/esp.h: $(DEPS_3)
	@echo '      [Copy] $(BUILD)/inc/esp.h'
	mkdir -p "$(BUILD)/inc"
	cp src/esp.h $(BUILD)/inc/esp.h

#
#   est.h
#
DEPS_4 += src/paks/est/est.h

$(BUILD)/inc/est.h: $(DEPS_4)
	@echo '      [Copy] $(BUILD)/inc/est.h'
	mkdir -p "$(BUILD)/inc"
	cp src/paks/est/est.h $(BUILD)/inc/est.h

#
#   me.h
#

$(BUILD)/inc/me.h: $(DEPS_5)

#
#   osdep.h
#
DEPS_6 += src/paks/osdep/osdep.h
DEPS_6 += $(BUILD)/inc/me.h

$(BUILD)/inc/osdep.h: $(DEPS_6)
	@echo '      [Copy] $(BUILD)/inc/osdep.h'
	mkdir -p "$(BUILD)/inc"
	cp src/paks/osdep/osdep.h $(BUILD)/inc/osdep.h

#
#   mpr.h
#
DEPS_7 += src/paks/mpr/mpr.h
DEPS_7 += $(BUILD)/inc/me.h
DEPS_7 += $(BUILD)/inc/osdep.h

$(BUILD)/inc/mpr.h: $(DEPS_7)
	@echo '      [Copy] $(BUILD)/inc/mpr.h'
	mkdir -p "$(BUILD)/inc"
	cp src/paks/mpr/mpr.h $(BUILD)/inc/mpr.h

#
#   http.h
#
DEPS_8 += src/paks/http/http.h
DEPS_8 += $(BUILD)/inc/mpr.h

$(BUILD)/inc/http.h: $(DEPS_8)
	@echo '      [Copy] $(BUILD)/inc/http.h'
	mkdir -p "$(BUILD)/inc"
	cp src/paks/http/http.h $(BUILD)/inc/http.h

#
#   mdb.h
#
DEPS_9 += src/mdb.h

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

$(BUILD)/inc/sqlite3.h: $(DEPS_11)
	@echo '      [Copy] $(BUILD)/inc/sqlite3.h'
	mkdir -p "$(BUILD)/inc"
	cp src/paks/sqlite/sqlite3.h $(BUILD)/inc/sqlite3.h

#
#   appweb.h
#

src/paks/appweb/appweb.h: $(DEPS_12)

#
#   appwebLib.o
#
DEPS_13 += src/paks/appweb/appweb.h
DEPS_13 += $(BUILD)/inc/pcre.h
DEPS_13 += $(BUILD)/inc/mpr.h

$(BUILD)/obj/appwebLib.o: \
    src/paks/appweb/appwebLib.c $(DEPS_13)
	@echo '   [Compile] $(BUILD)/obj/appwebLib.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/appwebLib.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/paks/appweb/appwebLib.c

#
#   edi.h
#

src/edi.h: $(DEPS_14)

#
#   edi.o
#
DEPS_15 += src/edi.h
DEPS_15 += $(BUILD)/inc/pcre.h

$(BUILD)/obj/edi.o: \
    src/edi.c $(DEPS_15)
	@echo '   [Compile] $(BUILD)/obj/edi.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/edi.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/edi.c

#
#   esp.h
#

src/esp.h: $(DEPS_16)

#
#   esp.o
#
DEPS_17 += src/esp.h

$(BUILD)/obj/esp.o: \
    src/esp.c $(DEPS_17)
	@echo '   [Compile] $(BUILD)/obj/esp.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/esp.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/esp.c

#
#   espAbbrev.o
#
DEPS_18 += src/esp.h

$(BUILD)/obj/espAbbrev.o: \
    src/espAbbrev.c $(DEPS_18)
	@echo '   [Compile] $(BUILD)/obj/espAbbrev.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/espAbbrev.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/espAbbrev.c

#
#   espConfig.o
#
DEPS_19 += src/esp.h

$(BUILD)/obj/espConfig.o: \
    src/espConfig.c $(DEPS_19)
	@echo '   [Compile] $(BUILD)/obj/espConfig.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/espConfig.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/espConfig.c

#
#   espFramework.o
#
DEPS_20 += src/esp.h

$(BUILD)/obj/espFramework.o: \
    src/espFramework.c $(DEPS_20)
	@echo '   [Compile] $(BUILD)/obj/espFramework.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/espFramework.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/espFramework.c

#
#   espHandler.o
#
DEPS_21 += src/esp.h

$(BUILD)/obj/espHandler.o: \
    src/espHandler.c $(DEPS_21)
	@echo '   [Compile] $(BUILD)/obj/espHandler.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/espHandler.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/espHandler.c

#
#   espHtml.o
#
DEPS_22 += src/esp.h
DEPS_22 += src/edi.h

$(BUILD)/obj/espHtml.o: \
    src/espHtml.c $(DEPS_22)
	@echo '   [Compile] $(BUILD)/obj/espHtml.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/espHtml.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/espHtml.c

#
#   espTemplate.o
#
DEPS_23 += src/esp.h

$(BUILD)/obj/espTemplate.o: \
    src/espTemplate.c $(DEPS_23)
	@echo '   [Compile] $(BUILD)/obj/espTemplate.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/espTemplate.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/espTemplate.c

#
#   est.h
#

src/paks/est/est.h: $(DEPS_24)

#
#   estLib.o
#
DEPS_25 += src/paks/est/est.h

$(BUILD)/obj/estLib.o: \
    src/paks/est/estLib.c $(DEPS_25)
	@echo '   [Compile] $(BUILD)/obj/estLib.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/estLib.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/paks/est/estLib.c

#
#   http.h
#

src/paks/http/http.h: $(DEPS_26)

#
#   httpLib.o
#
DEPS_27 += src/paks/http/http.h

$(BUILD)/obj/httpLib.o: \
    src/paks/http/httpLib.c $(DEPS_27)
	@echo '   [Compile] $(BUILD)/obj/httpLib.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/httpLib.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/paks/http/httpLib.c

#
#   mpr.h
#

src/paks/mpr/mpr.h: $(DEPS_28)

#
#   makerom.o
#
DEPS_29 += src/paks/mpr/mpr.h

$(BUILD)/obj/makerom.o: \
    src/paks/mpr/makerom.c $(DEPS_29)
	@echo '   [Compile] $(BUILD)/obj/makerom.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/makerom.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/paks/mpr/makerom.c

#
#   manager.o
#
DEPS_30 += src/paks/mpr/mpr.h

$(BUILD)/obj/manager.o: \
    src/paks/mpr/manager.c $(DEPS_30)
	@echo '   [Compile] $(BUILD)/obj/manager.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/manager.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/paks/mpr/manager.c

#
#   mdb.h
#

src/mdb.h: $(DEPS_31)

#
#   mdb.o
#
DEPS_32 += $(BUILD)/inc/http.h
DEPS_32 += src/edi.h
DEPS_32 += src/mdb.h
DEPS_32 += $(BUILD)/inc/pcre.h

$(BUILD)/obj/mdb.o: \
    src/mdb.c $(DEPS_32)
	@echo '   [Compile] $(BUILD)/obj/mdb.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/mdb.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/mdb.c

#
#   mprLib.o
#
DEPS_33 += src/paks/mpr/mpr.h

$(BUILD)/obj/mprLib.o: \
    src/paks/mpr/mprLib.c $(DEPS_33)
	@echo '   [Compile] $(BUILD)/obj/mprLib.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/mprLib.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/paks/mpr/mprLib.c

#
#   mprSsl.o
#
DEPS_34 += $(BUILD)/inc/me.h
DEPS_34 += src/paks/mpr/mpr.h

$(BUILD)/obj/mprSsl.o: \
    src/paks/mpr/mprSsl.c $(DEPS_34)
	@echo '   [Compile] $(BUILD)/obj/mprSsl.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/mprSsl.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) "-I$(ME_COM_OPENSSL_PATH)/include" src/paks/mpr/mprSsl.c

#
#   pcre.h
#

src/paks/pcre/pcre.h: $(DEPS_35)

#
#   pcre.o
#
DEPS_36 += $(BUILD)/inc/me.h
DEPS_36 += src/paks/pcre/pcre.h

$(BUILD)/obj/pcre.o: \
    src/paks/pcre/pcre.c $(DEPS_36)
	@echo '   [Compile] $(BUILD)/obj/pcre.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/pcre.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/paks/pcre/pcre.c

#
#   sdb.o
#
DEPS_37 += $(BUILD)/inc/http.h
DEPS_37 += src/edi.h

$(BUILD)/obj/sdb.o: \
    src/sdb.c $(DEPS_37)
	@echo '   [Compile] $(BUILD)/obj/sdb.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/sdb.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/sdb.c

#
#   sqlite3.h
#

src/paks/sqlite/sqlite3.h: $(DEPS_38)

#
#   sqlite.o
#
DEPS_39 += $(BUILD)/inc/me.h
DEPS_39 += src/paks/sqlite/sqlite3.h

$(BUILD)/obj/sqlite.o: \
    src/paks/sqlite/sqlite.c $(DEPS_39)
	@echo '   [Compile] $(BUILD)/obj/sqlite.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/sqlite.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/paks/sqlite/sqlite.c

#
#   sqlite3.o
#
DEPS_40 += $(BUILD)/inc/me.h
DEPS_40 += src/paks/sqlite/sqlite3.h

$(BUILD)/obj/sqlite3.o: \
    src/paks/sqlite/sqlite3.c $(DEPS_40)
	@echo '   [Compile] $(BUILD)/obj/sqlite3.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/sqlite3.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/paks/sqlite/sqlite3.c

#
#   esp-paks
#
DEPS_41 += src/paks/esp-html-mvc/client/assets/favicon.ico
DEPS_41 += src/paks/esp-html-mvc/client/css/all.css
DEPS_41 += src/paks/esp-html-mvc/client/css/all.less
DEPS_41 += src/paks/esp-html-mvc/client/index.esp
DEPS_41 += src/paks/esp-html-mvc/css/app.less
DEPS_41 += src/paks/esp-html-mvc/css/theme.less
DEPS_41 += src/paks/esp-html-mvc/generate/appweb.conf
DEPS_41 += src/paks/esp-html-mvc/generate/controller.c
DEPS_41 += src/paks/esp-html-mvc/generate/controllerSingleton.c
DEPS_41 += src/paks/esp-html-mvc/generate/edit.esp
DEPS_41 += src/paks/esp-html-mvc/generate/list.esp
DEPS_41 += src/paks/esp-html-mvc/layouts/default.esp
DEPS_41 += src/paks/esp-html-mvc/LICENSE.md
DEPS_41 += src/paks/esp-html-mvc/package.json
DEPS_41 += src/paks/esp-html-mvc/README.md
DEPS_41 += src/paks/esp-mvc/generate/appweb.conf
DEPS_41 += src/paks/esp-mvc/generate/controller.c
DEPS_41 += src/paks/esp-mvc/generate/migration.c
DEPS_41 += src/paks/esp-mvc/generate/src/app.c
DEPS_41 += src/paks/esp-mvc/LICENSE.md
DEPS_41 += src/paks/esp-mvc/package.json
DEPS_41 += src/paks/esp-mvc/README.md
DEPS_41 += src/paks/esp-server/generate/appweb.conf
DEPS_41 += src/paks/esp-server/LICENSE.md
DEPS_41 += src/paks/esp-server/package.json
DEPS_41 += src/paks/esp-server/README.md

$(BUILD)/esp: $(DEPS_41)
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
DEPS_42 += src/esp.conf

$(BUILD)/bin/esp.conf: $(DEPS_42)
	@echo '      [Copy] $(BUILD)/bin/esp.conf'
	mkdir -p "$(BUILD)/bin"
	cp src/esp.conf $(BUILD)/bin/esp.conf

#
#   libmpr
#
DEPS_43 += $(BUILD)/inc/osdep.h
DEPS_43 += $(BUILD)/inc/mpr.h
DEPS_43 += $(BUILD)/obj/mprLib.o

$(BUILD)/bin/libmpr.dylib: $(DEPS_43)
	@echo '      [Link] $(BUILD)/bin/libmpr.dylib'
	$(CC) -dynamiclib -o $(BUILD)/bin/libmpr.dylib -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) -install_name @rpath/libmpr.dylib -compatibility_version 5.2 -current_version 5.2 "$(BUILD)/obj/mprLib.o" $(LIBS) 

ifeq ($(ME_COM_PCRE),1)
#
#   libpcre
#
DEPS_44 += $(BUILD)/inc/pcre.h
DEPS_44 += $(BUILD)/obj/pcre.o

$(BUILD)/bin/libpcre.dylib: $(DEPS_44)
	@echo '      [Link] $(BUILD)/bin/libpcre.dylib'
	$(CC) -dynamiclib -o $(BUILD)/bin/libpcre.dylib -arch $(CC_ARCH) $(LDFLAGS) -compatibility_version 5.2 -current_version 5.2 $(LIBPATHS) -install_name @rpath/libpcre.dylib -compatibility_version 5.2 -current_version 5.2 "$(BUILD)/obj/pcre.o" $(LIBS) 
endif

ifeq ($(ME_COM_HTTP),1)
#
#   libhttp
#
DEPS_45 += $(BUILD)/bin/libmpr.dylib
ifeq ($(ME_COM_PCRE),1)
    DEPS_45 += $(BUILD)/bin/libpcre.dylib
endif
DEPS_45 += $(BUILD)/inc/http.h
DEPS_45 += $(BUILD)/obj/httpLib.o

LIBS_45 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_45 += -lpcre
endif

$(BUILD)/bin/libhttp.dylib: $(DEPS_45)
	@echo '      [Link] $(BUILD)/bin/libhttp.dylib'
	$(CC) -dynamiclib -o $(BUILD)/bin/libhttp.dylib -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) -install_name @rpath/libhttp.dylib -compatibility_version 5.2 -current_version 5.2 "$(BUILD)/obj/httpLib.o" $(LIBPATHS_45) $(LIBS_45) $(LIBS_45) $(LIBS) 
endif

ifeq ($(ME_COM_APPWEB),1)
#
#   libappweb
#
ifeq ($(ME_COM_HTTP),1)
    DEPS_46 += $(BUILD)/bin/libhttp.dylib
endif
ifeq ($(ME_COM_PCRE),1)
    DEPS_46 += $(BUILD)/bin/libpcre.dylib
endif
DEPS_46 += $(BUILD)/bin/libmpr.dylib
DEPS_46 += $(BUILD)/inc/appweb.h
DEPS_46 += $(BUILD)/obj/appwebLib.o

ifeq ($(ME_COM_HTTP),1)
    LIBS_46 += -lhttp
endif
LIBS_46 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_46 += -lpcre
endif

$(BUILD)/bin/libappweb.dylib: $(DEPS_46)
	@echo '      [Link] $(BUILD)/bin/libappweb.dylib'
	$(CC) -dynamiclib -o $(BUILD)/bin/libappweb.dylib -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) -install_name @rpath/libappweb.dylib -compatibility_version 5.2 -current_version 5.2 "$(BUILD)/obj/appwebLib.o" $(LIBPATHS_46) $(LIBS_46) $(LIBS_46) $(LIBS) 
endif

ifeq ($(ME_COM_SQLITE),1)
#
#   libsql
#
DEPS_47 += $(BUILD)/inc/sqlite3.h
DEPS_47 += $(BUILD)/obj/sqlite3.o

$(BUILD)/bin/libsql.dylib: $(DEPS_47)
	@echo '      [Link] $(BUILD)/bin/libsql.dylib'
	$(CC) -dynamiclib -o $(BUILD)/bin/libsql.dylib -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) -install_name @rpath/libsql.dylib -compatibility_version 5.2 -current_version 5.2 "$(BUILD)/obj/sqlite3.o" $(LIBS) 
endif

#
#   libmod_esp
#
ifeq ($(ME_COM_APPWEB),1)
    DEPS_48 += $(BUILD)/bin/libappweb.dylib
endif
ifeq ($(ME_COM_SQLITE),1)
    DEPS_48 += $(BUILD)/bin/libsql.dylib
endif
DEPS_48 += $(BUILD)/inc/edi.h
DEPS_48 += $(BUILD)/inc/esp.h
DEPS_48 += $(BUILD)/inc/mdb.h
DEPS_48 += $(BUILD)/obj/edi.o
DEPS_48 += $(BUILD)/obj/espAbbrev.o
DEPS_48 += $(BUILD)/obj/espConfig.o
DEPS_48 += $(BUILD)/obj/espFramework.o
DEPS_48 += $(BUILD)/obj/espHandler.o
DEPS_48 += $(BUILD)/obj/espHtml.o
DEPS_48 += $(BUILD)/obj/espTemplate.o
DEPS_48 += $(BUILD)/obj/mdb.o
DEPS_48 += $(BUILD)/obj/sdb.o

ifeq ($(ME_COM_APPWEB),1)
    LIBS_48 += -lappweb
endif
ifeq ($(ME_COM_HTTP),1)
    LIBS_48 += -lhttp
endif
LIBS_48 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_48 += -lpcre
endif
ifeq ($(ME_COM_SQLITE),1)
    LIBS_48 += -lsql
endif

$(BUILD)/bin/libmod_esp.dylib: $(DEPS_48)
	@echo '      [Link] $(BUILD)/bin/libmod_esp.dylib'
	$(CC) -dynamiclib -o $(BUILD)/bin/libmod_esp.dylib -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) -install_name @rpath/libmod_esp.dylib -compatibility_version 5.2 -current_version 5.2 "$(BUILD)/obj/edi.o" "$(BUILD)/obj/espAbbrev.o" "$(BUILD)/obj/espConfig.o" "$(BUILD)/obj/espFramework.o" "$(BUILD)/obj/espHandler.o" "$(BUILD)/obj/espHtml.o" "$(BUILD)/obj/espTemplate.o" "$(BUILD)/obj/mdb.o" "$(BUILD)/obj/sdb.o" $(LIBPATHS_48) $(LIBS_48) $(LIBS_48) $(LIBS) 

#
#   espcmd
#
ifeq ($(ME_COM_APPWEB),1)
    DEPS_49 += $(BUILD)/bin/libappweb.dylib
endif
ifeq ($(ME_COM_SQLITE),1)
    DEPS_49 += $(BUILD)/bin/libsql.dylib
endif
DEPS_49 += $(BUILD)/bin/libmod_esp.dylib
DEPS_49 += $(BUILD)/obj/esp.o

ifeq ($(ME_COM_APPWEB),1)
    LIBS_49 += -lappweb
endif
ifeq ($(ME_COM_HTTP),1)
    LIBS_49 += -lhttp
endif
LIBS_49 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_49 += -lpcre
endif
ifeq ($(ME_COM_SQLITE),1)
    LIBS_49 += -lsql
endif
LIBS_49 += -lmod_esp

$(BUILD)/bin/esp: $(DEPS_49)
	@echo '      [Link] $(BUILD)/bin/esp'
	$(CC) -o $(BUILD)/bin/esp -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/esp.o" $(LIBPATHS_49) $(LIBS_49) $(LIBS_49) $(LIBS) 

#
#   http-ca-crt
#
DEPS_50 += src/paks/http/ca.crt

$(BUILD)/bin/ca.crt: $(DEPS_50)
	@echo '      [Copy] $(BUILD)/bin/ca.crt'
	mkdir -p "$(BUILD)/bin"
	cp src/paks/http/ca.crt $(BUILD)/bin/ca.crt

ifeq ($(ME_COM_EST),1)
#
#   libest
#
DEPS_51 += $(BUILD)/inc/osdep.h
DEPS_51 += $(BUILD)/inc/est.h
DEPS_51 += $(BUILD)/obj/estLib.o

$(BUILD)/bin/libest.dylib: $(DEPS_51)
	@echo '      [Link] $(BUILD)/bin/libest.dylib'
	$(CC) -dynamiclib -o $(BUILD)/bin/libest.dylib -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) -install_name @rpath/libest.dylib -compatibility_version 5.2 -current_version 5.2 "$(BUILD)/obj/estLib.o" $(LIBS) 
endif

#
#   libmprssl
#
DEPS_52 += $(BUILD)/bin/libmpr.dylib
ifeq ($(ME_COM_EST),1)
    DEPS_52 += $(BUILD)/bin/libest.dylib
endif
DEPS_52 += $(BUILD)/obj/mprSsl.o

LIBS_52 += -lmpr
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_52 += -lssl
    LIBPATHS_52 += -L$(ME_COM_OPENSSL_PATH)
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_52 += -lcrypto
    LIBPATHS_52 += -L$(ME_COM_OPENSSL_PATH)
endif
ifeq ($(ME_COM_EST),1)
    LIBS_52 += -lest
endif

$(BUILD)/bin/libmprssl.dylib: $(DEPS_52)
	@echo '      [Link] $(BUILD)/bin/libmprssl.dylib'
	$(CC) -dynamiclib -o $(BUILD)/bin/libmprssl.dylib -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS)  -install_name @rpath/libmprssl.dylib -compatibility_version 5.2 -current_version 5.2 "$(BUILD)/obj/mprSsl.o" $(LIBPATHS_52) $(LIBS_52) $(LIBS_52) $(LIBS) 

#
#   makerom
#
DEPS_53 += $(BUILD)/bin/libmpr.dylib
DEPS_53 += $(BUILD)/obj/makerom.o

LIBS_53 += -lmpr

$(BUILD)/bin/makerom: $(DEPS_53)
	@echo '      [Link] $(BUILD)/bin/makerom'
	$(CC) -o $(BUILD)/bin/makerom -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/makerom.o" $(LIBPATHS_53) $(LIBS_53) $(LIBS_53) $(LIBS) 

#
#   manager
#
DEPS_54 += $(BUILD)/bin/libmpr.dylib
DEPS_54 += $(BUILD)/obj/manager.o

LIBS_54 += -lmpr

$(BUILD)/bin/espman: $(DEPS_54)
	@echo '      [Link] $(BUILD)/bin/espman'
	$(CC) -o $(BUILD)/bin/espman -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/manager.o" $(LIBPATHS_54) $(LIBS_54) $(LIBS_54) $(LIBS) 

ifeq ($(ME_COM_SQLITE),1)
#
#   sqliteshell
#
DEPS_55 += $(BUILD)/bin/libsql.dylib
DEPS_55 += $(BUILD)/obj/sqlite.o

LIBS_55 += -lsql

$(BUILD)/bin/sqlite: $(DEPS_55)
	@echo '      [Link] $(BUILD)/bin/sqlite'
	$(CC) -o $(BUILD)/bin/sqlite -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/sqlite.o" $(LIBPATHS_55) $(LIBS_55) $(LIBS_55) $(LIBS) 
endif


#
#   installBinary
#

installBinary: $(DEPS_56)
	( \
	cd ../../.paks/me-package/0.8.4; \
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
	cp ../../../git/esp/src/paks/esp-html-mvc/client/assets/favicon.ico $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.2.0/client/assets/favicon.ico ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.2.0/client/css" ; \
	cp ../../../git/esp/src/paks/esp-html-mvc/client/css/all.css $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.2.0/client/css/all.css ; \
	cp ../../../git/esp/src/paks/esp-html-mvc/client/css/all.less $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.2.0/client/css/all.less ; \
	cp ../../../git/esp/src/paks/esp-html-mvc/client/index.esp $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.2.0/client/index.esp ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.2.0/css" ; \
	cp ../../../git/esp/src/paks/esp-html-mvc/css/app.less $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.2.0/css/app.less ; \
	cp ../../../git/esp/src/paks/esp-html-mvc/css/theme.less $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.2.0/css/theme.less ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.2.0/generate" ; \
	cp ../../../git/esp/src/paks/esp-html-mvc/generate/appweb.conf $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.2.0/generate/appweb.conf ; \
	cp ../../../git/esp/src/paks/esp-html-mvc/generate/controller.c $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.2.0/generate/controller.c ; \
	cp ../../../git/esp/src/paks/esp-html-mvc/generate/controllerSingleton.c $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.2.0/generate/controllerSingleton.c ; \
	cp ../../../git/esp/src/paks/esp-html-mvc/generate/edit.esp $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.2.0/generate/edit.esp ; \
	cp ../../../git/esp/src/paks/esp-html-mvc/generate/list.esp $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.2.0/generate/list.esp ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.2.0/layouts" ; \
	cp ../../../git/esp/src/paks/esp-html-mvc/layouts/default.esp $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.2.0/layouts/default.esp ; \
	cp ../../../git/esp/src/paks/esp-html-mvc/LICENSE.md $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.2.0/LICENSE.md ; \
	cp ../../../git/esp/src/paks/esp-html-mvc/package.json $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.2.0/package.json ; \
	cp ../../../git/esp/src/paks/esp-html-mvc/README.md $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.2.0/README.md ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-mvc/5.2.0" ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-mvc/5.2.0/generate" ; \
	cp ../../../git/esp/src/paks/esp-mvc/generate/appweb.conf $(ME_VAPP_PREFIX)/esp/esp-mvc/5.2.0/generate/appweb.conf ; \
	cp ../../../git/esp/src/paks/esp-mvc/generate/controller.c $(ME_VAPP_PREFIX)/esp/esp-mvc/5.2.0/generate/controller.c ; \
	cp ../../../git/esp/src/paks/esp-mvc/generate/migration.c $(ME_VAPP_PREFIX)/esp/esp-mvc/5.2.0/generate/migration.c ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-mvc/5.2.0/generate/src" ; \
	cp ../../../git/esp/src/paks/esp-mvc/generate/src/app.c $(ME_VAPP_PREFIX)/esp/esp-mvc/5.2.0/generate/src/app.c ; \
	cp ../../../git/esp/src/paks/esp-mvc/LICENSE.md $(ME_VAPP_PREFIX)/esp/esp-mvc/5.2.0/LICENSE.md ; \
	cp ../../../git/esp/src/paks/esp-mvc/package.json $(ME_VAPP_PREFIX)/esp/esp-mvc/5.2.0/package.json ; \
	cp ../../../git/esp/src/paks/esp-mvc/README.md $(ME_VAPP_PREFIX)/esp/esp-mvc/5.2.0/README.md ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-server/5.2.0" ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-server/5.2.0/generate" ; \
	cp ../../../git/esp/src/paks/esp-server/generate/appweb.conf $(ME_VAPP_PREFIX)/esp/esp-server/5.2.0/generate/appweb.conf ; \
	cp ../../../git/esp/src/paks/esp-server/LICENSE.md $(ME_VAPP_PREFIX)/esp/esp-server/5.2.0/LICENSE.md ; \
	cp ../../../git/esp/src/paks/esp-server/package.json $(ME_VAPP_PREFIX)/esp/esp-server/5.2.0/package.json ; \
	cp ../../../git/esp/src/paks/esp-server/README.md $(ME_VAPP_PREFIX)/esp/esp-server/5.2.0/README.md ; \
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
	ln -s "$(ME_VAPP_PREFIX)/doc/man/man1/esp.1" "$(ME_MAN_PREFIX)/man1/esp.1" ; \
	)


#
#   install
#
DEPS_57 += stop
DEPS_57 += installBinary
DEPS_57 += start

install: $(DEPS_57)

#
#   uninstall
#
DEPS_58 += stop

uninstall: $(DEPS_58)
	( \
	cd ../../.paks/me-package/0.8.4; \
	rm -fr "$(ME_VAPP_PREFIX)" ; \
	rm -f "$(ME_APP_PREFIX)/latest" ; \
	rmdir -p "$(ME_APP_PREFIX)" 2>/dev/null ; true ; \
	)

#
#   version
#

version: $(DEPS_59)
	echo 5.2.0

