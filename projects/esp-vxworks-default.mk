#
#   esp-vxworks-default.mk -- Makefile to build Embedthis ESP for vxworks
#

NAME                  := esp
VERSION               := 5.1.0
PROFILE               ?= default
ARCH                  ?= $(shell echo $(WIND_HOST_TYPE) | sed 's/-.*//')
CPU                   ?= $(subst X86,PENTIUM,$(shell echo $(ARCH) | tr a-z A-Z))
OS                    ?= vxworks
CC                    ?= cc$(subst x86,pentium,$(ARCH))
LD                    ?= ld
CONFIG                ?= $(OS)-$(ARCH)-$(PROFILE)
BUILD                 ?= build/$(CONFIG)
LBIN                  ?= $(BUILD)/bin
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

ME_COM_COMPILER_PATH  ?= cc$(subst x86,pentium,$(ARCH))
ME_COM_LIB_PATH       ?= ar
ME_COM_LINK_PATH      ?= ld
ME_COM_MATRIXSSL_PATH ?= /usr/src/matrixssl
ME_COM_NANOSSL_PATH   ?= /usr/src/nanossl
ME_COM_OPENSSL_PATH   ?= /usr/src/openssl
ME_COM_VXWORKS_PATH   ?= $(WIND_BASE)

export WIND_HOME      ?= $(WIND_BASE)/..
export PATH           := $(WIND_GNU_PATH)/$(WIND_HOST_TYPE)/bin:$(PATH)

CFLAGS                += -fno-builtin -fno-defer-pop -fvolatile -w
DFLAGS                += -DVXWORKS -DRW_MULTI_THREAD -D_GNU_TOOL -DCPU=PENTIUM $(patsubst %,-D%,$(filter ME_%,$(MAKEFLAGS))) -DME_COM_APPWEB=$(ME_COM_APPWEB) -DME_COM_CGI=$(ME_COM_CGI) -DME_COM_DIR=$(ME_COM_DIR) -DME_COM_EST=$(ME_COM_EST) -DME_COM_HTTP=$(ME_COM_HTTP) -DME_COM_MATRIXSSL=$(ME_COM_MATRIXSSL) -DME_COM_MDB=$(ME_COM_MDB) -DME_COM_NANOSSL=$(ME_COM_NANOSSL) -DME_COM_OPENSSL=$(ME_COM_OPENSSL) -DME_COM_PCRE=$(ME_COM_PCRE) -DME_COM_SQLITE=$(ME_COM_SQLITE) -DME_COM_SSL=$(ME_COM_SSL) -DME_COM_WINSDK=$(ME_COM_WINSDK) 
IFLAGS                += "-Ibuild/$(CONFIG)/inc -I$(WIND_BASE)/target/h -I$(WIND_BASE)/target/h/wrn/coreip"
LDFLAGS               += '-Wl,-r'
LIBPATHS              += -Lbuild/$(CONFIG)/bin
LIBS                  += -lgcc

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

ME_ROOT_PREFIX        ?= deploy
ME_BASE_PREFIX        ?= $(ME_ROOT_PREFIX)
ME_DATA_PREFIX        ?= $(ME_VAPP_PREFIX)
ME_STATE_PREFIX       ?= $(ME_VAPP_PREFIX)
ME_BIN_PREFIX         ?= $(ME_VAPP_PREFIX)
ME_INC_PREFIX         ?= $(ME_VAPP_PREFIX)/inc
ME_LIB_PREFIX         ?= $(ME_VAPP_PREFIX)
ME_MAN_PREFIX         ?= $(ME_VAPP_PREFIX)
ME_SBIN_PREFIX        ?= $(ME_VAPP_PREFIX)
ME_ETC_PREFIX         ?= $(ME_VAPP_PREFIX)
ME_WEB_PREFIX         ?= $(ME_VAPP_PREFIX)/web
ME_LOG_PREFIX         ?= $(ME_VAPP_PREFIX)
ME_SPOOL_PREFIX       ?= $(ME_VAPP_PREFIX)
ME_CACHE_PREFIX       ?= $(ME_VAPP_PREFIX)
ME_APP_PREFIX         ?= $(ME_BASE_PREFIX)
ME_VAPP_PREFIX        ?= $(ME_APP_PREFIX)
ME_SRC_PREFIX         ?= $(ME_ROOT_PREFIX)/usr/src/$(NAME)-$(VERSION)


TARGETS               += build/$(CONFIG)/esp
TARGETS               += build/$(CONFIG)/bin/esp.conf
TARGETS               += build/$(CONFIG)/bin/esp.out
TARGETS               += build/$(CONFIG)/bin/ca.crt
ifeq ($(ME_COM_EST),1)
    TARGETS           += build/$(CONFIG)/bin/libest.out
endif
TARGETS               += build/$(CONFIG)/bin/libmprssl.out
TARGETS               += build/$(CONFIG)/bin/espman.out
ifeq ($(ME_COM_SQLITE),1)
    TARGETS           += build/$(CONFIG)/bin/sqlite.out
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
	@if [ "$(WIND_BASE)" = "" ] ; then echo WARNING: WIND_BASE not set. Run wrenv.sh. ; exit 255 ; fi
	@if [ "$(WIND_HOST_TYPE)" = "" ] ; then echo WARNING: WIND_HOST_TYPE not set. Run wrenv.sh. ; exit 255 ; fi
	@if [ "$(WIND_GNU_PATH)" = "" ] ; then echo WARNING: WIND_GNU_PATH not set. Run wrenv.sh. ; exit 255 ; fi
	@[ ! -x $(BUILD)/bin ] && mkdir -p $(BUILD)/bin; true
	@[ ! -x $(BUILD)/inc ] && mkdir -p $(BUILD)/inc; true
	@[ ! -x $(BUILD)/obj ] && mkdir -p $(BUILD)/obj; true
	@[ ! -f $(BUILD)/inc/me.h ] && cp projects/esp-vxworks-default-me.h $(BUILD)/inc/me.h ; true
	@if ! diff $(BUILD)/inc/me.h projects/esp-vxworks-default-me.h >/dev/null ; then\
		cp projects/esp-vxworks-default-me.h $(BUILD)/inc/me.h  ; \
	fi; true
	@if [ -f "$(BUILD)/.makeflags" ] ; then \
		if [ "$(MAKEFLAGS)" != "`cat $(BUILD)/.makeflags`" ] ; then \
			echo "   [Warning] Make flags have changed since the last build: "`cat $(BUILD)/.makeflags`"" ; \
		fi ; \
	fi
	@echo $(MAKEFLAGS) >$(BUILD)/.makeflags

clean:
	rm -f "build/$(CONFIG)/obj/appwebLib.o"
	rm -f "build/$(CONFIG)/obj/edi.o"
	rm -f "build/$(CONFIG)/obj/esp.o"
	rm -f "build/$(CONFIG)/obj/espAbbrev.o"
	rm -f "build/$(CONFIG)/obj/espConfig.o"
	rm -f "build/$(CONFIG)/obj/espFramework.o"
	rm -f "build/$(CONFIG)/obj/espHandler.o"
	rm -f "build/$(CONFIG)/obj/espHtml.o"
	rm -f "build/$(CONFIG)/obj/espTemplate.o"
	rm -f "build/$(CONFIG)/obj/estLib.o"
	rm -f "build/$(CONFIG)/obj/httpLib.o"
	rm -f "build/$(CONFIG)/obj/manager.o"
	rm -f "build/$(CONFIG)/obj/mdb.o"
	rm -f "build/$(CONFIG)/obj/mprLib.o"
	rm -f "build/$(CONFIG)/obj/mprSsl.o"
	rm -f "build/$(CONFIG)/obj/pcre.o"
	rm -f "build/$(CONFIG)/obj/sdb.o"
	rm -f "build/$(CONFIG)/obj/sqlite.o"
	rm -f "build/$(CONFIG)/obj/sqlite3.o"
	rm -f "build/$(CONFIG)/bin/esp.conf"
	rm -f "build/$(CONFIG)/bin/esp.out"
	rm -f "build/$(CONFIG)/bin/ca.crt"
	rm -f "build/$(CONFIG)/bin/libappweb.out"
	rm -f "build/$(CONFIG)/bin/libest.out"
	rm -f "build/$(CONFIG)/bin/libhttp.out"
	rm -f "build/$(CONFIG)/bin/libmod_esp.out"
	rm -f "build/$(CONFIG)/bin/libmpr.out"
	rm -f "build/$(CONFIG)/bin/libmprssl.out"
	rm -f "build/$(CONFIG)/bin/libpcre.out"
	rm -f "build/$(CONFIG)/bin/libsql.out"
	rm -f "build/$(CONFIG)/bin/espman.out"
	rm -f "build/$(CONFIG)/bin/sqlite.out"

clobber: clean
	rm -fr ./$(BUILD)


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

build/$(CONFIG)/esp: $(DEPS_1)
	( \
	cd src/paks; \
	mkdir -p "../../build/$(CONFIG)/esp/esp-html-mvc/5.1.0" ; \
	mkdir -p "../../build/$(CONFIG)/esp/esp-html-mvc/5.1.0/client" ; \
	mkdir -p "../../build/$(CONFIG)/esp/esp-html-mvc/5.1.0/client/assets" ; \
	cp esp-html-mvc/client/assets/favicon.ico ../../build/$(CONFIG)/esp/esp-html-mvc/5.1.0/client/assets/favicon.ico ; \
	mkdir -p "../../build/$(CONFIG)/esp/esp-html-mvc/5.1.0/client/css" ; \
	cp esp-html-mvc/client/css/all.css ../../build/$(CONFIG)/esp/esp-html-mvc/5.1.0/client/css/all.css ; \
	cp esp-html-mvc/client/css/all.less ../../build/$(CONFIG)/esp/esp-html-mvc/5.1.0/client/css/all.less ; \
	cp esp-html-mvc/client/index.esp ../../build/$(CONFIG)/esp/esp-html-mvc/5.1.0/client/index.esp ; \
	mkdir -p "../../build/$(CONFIG)/esp/esp-html-mvc/5.1.0/css" ; \
	cp esp-html-mvc/css/app.less ../../build/$(CONFIG)/esp/esp-html-mvc/5.1.0/css/app.less ; \
	cp esp-html-mvc/css/theme.less ../../build/$(CONFIG)/esp/esp-html-mvc/5.1.0/css/theme.less ; \
	mkdir -p "../../build/$(CONFIG)/esp/esp-html-mvc/5.1.0/generate" ; \
	cp esp-html-mvc/generate/appweb.conf ../../build/$(CONFIG)/esp/esp-html-mvc/5.1.0/generate/appweb.conf ; \
	cp esp-html-mvc/generate/controller.c ../../build/$(CONFIG)/esp/esp-html-mvc/5.1.0/generate/controller.c ; \
	cp esp-html-mvc/generate/controllerSingleton.c ../../build/$(CONFIG)/esp/esp-html-mvc/5.1.0/generate/controllerSingleton.c ; \
	cp esp-html-mvc/generate/edit.esp ../../build/$(CONFIG)/esp/esp-html-mvc/5.1.0/generate/edit.esp ; \
	cp esp-html-mvc/generate/list.esp ../../build/$(CONFIG)/esp/esp-html-mvc/5.1.0/generate/list.esp ; \
	mkdir -p "../../build/$(CONFIG)/esp/esp-html-mvc/5.1.0/layouts" ; \
	cp esp-html-mvc/layouts/default.esp ../../build/$(CONFIG)/esp/esp-html-mvc/5.1.0/layouts/default.esp ; \
	cp esp-html-mvc/LICENSE.md ../../build/$(CONFIG)/esp/esp-html-mvc/5.1.0/LICENSE.md ; \
	cp esp-html-mvc/package.json ../../build/$(CONFIG)/esp/esp-html-mvc/5.1.0/package.json ; \
	cp esp-html-mvc/README.md ../../build/$(CONFIG)/esp/esp-html-mvc/5.1.0/README.md ; \
	mkdir -p "../../build/$(CONFIG)/esp/esp-mvc/5.1.0" ; \
	mkdir -p "../../build/$(CONFIG)/esp/esp-mvc/5.1.0/generate" ; \
	cp esp-mvc/generate/appweb.conf ../../build/$(CONFIG)/esp/esp-mvc/5.1.0/generate/appweb.conf ; \
	cp esp-mvc/generate/controller.c ../../build/$(CONFIG)/esp/esp-mvc/5.1.0/generate/controller.c ; \
	cp esp-mvc/generate/migration.c ../../build/$(CONFIG)/esp/esp-mvc/5.1.0/generate/migration.c ; \
	mkdir -p "../../build/$(CONFIG)/esp/esp-mvc/5.1.0/generate/src" ; \
	cp esp-mvc/generate/src/app.c ../../build/$(CONFIG)/esp/esp-mvc/5.1.0/generate/src/app.c ; \
	cp esp-mvc/LICENSE.md ../../build/$(CONFIG)/esp/esp-mvc/5.1.0/LICENSE.md ; \
	cp esp-mvc/package.json ../../build/$(CONFIG)/esp/esp-mvc/5.1.0/package.json ; \
	cp esp-mvc/README.md ../../build/$(CONFIG)/esp/esp-mvc/5.1.0/README.md ; \
	mkdir -p "../../build/$(CONFIG)/esp/esp-server/5.1.0" ; \
	mkdir -p "../../build/$(CONFIG)/esp/esp-server/5.1.0/generate" ; \
	cp esp-server/generate/appweb.conf ../../build/$(CONFIG)/esp/esp-server/5.1.0/generate/appweb.conf ; \
	cp esp-server/LICENSE.md ../../build/$(CONFIG)/esp/esp-server/5.1.0/LICENSE.md ; \
	cp esp-server/package.json ../../build/$(CONFIG)/esp/esp-server/5.1.0/package.json ; \
	cp esp-server/README.md ../../build/$(CONFIG)/esp/esp-server/5.1.0/README.md ; \
	)

#
#   esp.conf
#
DEPS_2 += src/esp.conf

build/$(CONFIG)/bin/esp.conf: $(DEPS_2)
	@echo '      [Copy] build/$(CONFIG)/bin/esp.conf'
	mkdir -p "build/$(CONFIG)/bin"
	cp src/esp.conf build/$(CONFIG)/bin/esp.conf

#
#   mpr.h
#
build/$(CONFIG)/inc/mpr.h: $(DEPS_3)
	@echo '      [Copy] build/$(CONFIG)/inc/mpr.h'
	mkdir -p "build/$(CONFIG)/inc"
	cp src/paks/mpr/mpr.h build/$(CONFIG)/inc/mpr.h

#
#   me.h
#
build/$(CONFIG)/inc/me.h: $(DEPS_4)
	@echo '      [Copy] build/$(CONFIG)/inc/me.h'

#
#   osdep.h
#
build/$(CONFIG)/inc/osdep.h: $(DEPS_5)
	@echo '      [Copy] build/$(CONFIG)/inc/osdep.h'
	mkdir -p "build/$(CONFIG)/inc"
	cp src/paks/osdep/osdep.h build/$(CONFIG)/inc/osdep.h

#
#   mprLib.o
#
DEPS_6 += build/$(CONFIG)/inc/me.h
DEPS_6 += build/$(CONFIG)/inc/mpr.h
DEPS_6 += build/$(CONFIG)/inc/osdep.h

build/$(CONFIG)/obj/mprLib.o: \
    src/paks/mpr/mprLib.c $(DEPS_6)
	@echo '   [Compile] build/$(CONFIG)/obj/mprLib.o'
	$(CC) -c -o build/$(CONFIG)/obj/mprLib.o $(CFLAGS) $(DFLAGS) "-Ibuild/$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/paks/mpr/mprLib.c

#
#   libmpr
#
DEPS_7 += build/$(CONFIG)/inc/mpr.h
DEPS_7 += build/$(CONFIG)/inc/me.h
DEPS_7 += build/$(CONFIG)/inc/osdep.h
DEPS_7 += build/$(CONFIG)/obj/mprLib.o

build/$(CONFIG)/bin/libmpr.out: $(DEPS_7)
	@echo '      [Link] build/$(CONFIG)/bin/libmpr.out'
	$(CC) -r -o build/$(CONFIG)/bin/libmpr.out $(LDFLAGS) $(LIBPATHS) "build/$(CONFIG)/obj/mprLib.o" $(LIBS) 

#
#   pcre.h
#
build/$(CONFIG)/inc/pcre.h: $(DEPS_8)
	@echo '      [Copy] build/$(CONFIG)/inc/pcre.h'
	mkdir -p "build/$(CONFIG)/inc"
	cp src/paks/pcre/pcre.h build/$(CONFIG)/inc/pcre.h

#
#   pcre.o
#
DEPS_9 += build/$(CONFIG)/inc/me.h
DEPS_9 += build/$(CONFIG)/inc/pcre.h

build/$(CONFIG)/obj/pcre.o: \
    src/paks/pcre/pcre.c $(DEPS_9)
	@echo '   [Compile] build/$(CONFIG)/obj/pcre.o'
	$(CC) -c -o build/$(CONFIG)/obj/pcre.o $(CFLAGS) $(DFLAGS) "-Ibuild/$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/paks/pcre/pcre.c

ifeq ($(ME_COM_PCRE),1)
#
#   libpcre
#
DEPS_10 += build/$(CONFIG)/inc/pcre.h
DEPS_10 += build/$(CONFIG)/inc/me.h
DEPS_10 += build/$(CONFIG)/obj/pcre.o

build/$(CONFIG)/bin/libpcre.out: $(DEPS_10)
	@echo '      [Link] build/$(CONFIG)/bin/libpcre.out'
	$(CC) -r -o build/$(CONFIG)/bin/libpcre.out $(LDFLAGS) $(LIBPATHS) "build/$(CONFIG)/obj/pcre.o" $(LIBS) 
endif

#
#   http.h
#
build/$(CONFIG)/inc/http.h: $(DEPS_11)
	@echo '      [Copy] build/$(CONFIG)/inc/http.h'
	mkdir -p "build/$(CONFIG)/inc"
	cp src/paks/http/http.h build/$(CONFIG)/inc/http.h

#
#   httpLib.o
#
DEPS_12 += build/$(CONFIG)/inc/me.h
DEPS_12 += build/$(CONFIG)/inc/http.h
DEPS_12 += build/$(CONFIG)/inc/mpr.h

build/$(CONFIG)/obj/httpLib.o: \
    src/paks/http/httpLib.c $(DEPS_12)
	@echo '   [Compile] build/$(CONFIG)/obj/httpLib.o'
	$(CC) -c -o build/$(CONFIG)/obj/httpLib.o $(CFLAGS) $(DFLAGS) "-Ibuild/$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/paks/http/httpLib.c

ifeq ($(ME_COM_HTTP),1)
#
#   libhttp
#
DEPS_13 += build/$(CONFIG)/inc/mpr.h
DEPS_13 += build/$(CONFIG)/inc/me.h
DEPS_13 += build/$(CONFIG)/inc/osdep.h
DEPS_13 += build/$(CONFIG)/obj/mprLib.o
DEPS_13 += build/$(CONFIG)/bin/libmpr.out
DEPS_13 += build/$(CONFIG)/inc/pcre.h
DEPS_13 += build/$(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_13 += build/$(CONFIG)/bin/libpcre.out
endif
DEPS_13 += build/$(CONFIG)/inc/http.h
DEPS_13 += build/$(CONFIG)/obj/httpLib.o

build/$(CONFIG)/bin/libhttp.out: $(DEPS_13)
	@echo '      [Link] build/$(CONFIG)/bin/libhttp.out'
	$(CC) -r -o build/$(CONFIG)/bin/libhttp.out $(LDFLAGS) $(LIBPATHS) "build/$(CONFIG)/obj/httpLib.o" $(LIBS) 
endif

#
#   appweb.h
#
build/$(CONFIG)/inc/appweb.h: $(DEPS_14)
	@echo '      [Copy] build/$(CONFIG)/inc/appweb.h'
	mkdir -p "build/$(CONFIG)/inc"
	cp src/paks/appweb/appweb.h build/$(CONFIG)/inc/appweb.h

#
#   appwebLib.o
#
DEPS_15 += build/$(CONFIG)/inc/me.h
DEPS_15 += build/$(CONFIG)/inc/appweb.h
DEPS_15 += build/$(CONFIG)/inc/pcre.h
DEPS_15 += build/$(CONFIG)/inc/mpr.h
DEPS_15 += build/$(CONFIG)/inc/osdep.h
DEPS_15 += build/$(CONFIG)/inc/http.h

build/$(CONFIG)/obj/appwebLib.o: \
    src/paks/appweb/appwebLib.c $(DEPS_15)
	@echo '   [Compile] build/$(CONFIG)/obj/appwebLib.o'
	$(CC) -c -o build/$(CONFIG)/obj/appwebLib.o $(CFLAGS) $(DFLAGS) "-Ibuild/$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/paks/appweb/appwebLib.c

ifeq ($(ME_COM_APPWEB),1)
#
#   libappweb
#
DEPS_16 += build/$(CONFIG)/inc/mpr.h
DEPS_16 += build/$(CONFIG)/inc/me.h
DEPS_16 += build/$(CONFIG)/inc/osdep.h
DEPS_16 += build/$(CONFIG)/obj/mprLib.o
DEPS_16 += build/$(CONFIG)/bin/libmpr.out
DEPS_16 += build/$(CONFIG)/inc/pcre.h
DEPS_16 += build/$(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_16 += build/$(CONFIG)/bin/libpcre.out
endif
DEPS_16 += build/$(CONFIG)/inc/http.h
DEPS_16 += build/$(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_16 += build/$(CONFIG)/bin/libhttp.out
endif
DEPS_16 += build/$(CONFIG)/inc/appweb.h
DEPS_16 += build/$(CONFIG)/obj/appwebLib.o

build/$(CONFIG)/bin/libappweb.out: $(DEPS_16)
	@echo '      [Link] build/$(CONFIG)/bin/libappweb.out'
	$(CC) -r -o build/$(CONFIG)/bin/libappweb.out $(LDFLAGS) $(LIBPATHS) "build/$(CONFIG)/obj/appwebLib.o" $(LIBS) 
endif

#
#   sqlite3.h
#
build/$(CONFIG)/inc/sqlite3.h: $(DEPS_17)
	@echo '      [Copy] build/$(CONFIG)/inc/sqlite3.h'
	mkdir -p "build/$(CONFIG)/inc"
	cp src/paks/sqlite/sqlite3.h build/$(CONFIG)/inc/sqlite3.h

#
#   sqlite3.o
#
DEPS_18 += build/$(CONFIG)/inc/me.h
DEPS_18 += build/$(CONFIG)/inc/sqlite3.h

build/$(CONFIG)/obj/sqlite3.o: \
    src/paks/sqlite/sqlite3.c $(DEPS_18)
	@echo '   [Compile] build/$(CONFIG)/obj/sqlite3.o'
	$(CC) -c -o build/$(CONFIG)/obj/sqlite3.o $(CFLAGS) $(DFLAGS) "-Ibuild/$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/paks/sqlite/sqlite3.c

ifeq ($(ME_COM_SQLITE),1)
#
#   libsql
#
DEPS_19 += build/$(CONFIG)/inc/sqlite3.h
DEPS_19 += build/$(CONFIG)/inc/me.h
DEPS_19 += build/$(CONFIG)/obj/sqlite3.o

build/$(CONFIG)/bin/libsql.out: $(DEPS_19)
	@echo '      [Link] build/$(CONFIG)/bin/libsql.out'
	$(CC) -r -o build/$(CONFIG)/bin/libsql.out $(LDFLAGS) $(LIBPATHS) "build/$(CONFIG)/obj/sqlite3.o" $(LIBS) 
endif

#
#   edi.h
#
build/$(CONFIG)/inc/edi.h: $(DEPS_20)
	@echo '      [Copy] build/$(CONFIG)/inc/edi.h'
	mkdir -p "build/$(CONFIG)/inc"
	cp src/edi.h build/$(CONFIG)/inc/edi.h

#
#   esp.h
#
build/$(CONFIG)/inc/esp.h: $(DEPS_21)
	@echo '      [Copy] build/$(CONFIG)/inc/esp.h'
	mkdir -p "build/$(CONFIG)/inc"
	cp src/esp.h build/$(CONFIG)/inc/esp.h

#
#   mdb.h
#
build/$(CONFIG)/inc/mdb.h: $(DEPS_22)
	@echo '      [Copy] build/$(CONFIG)/inc/mdb.h'
	mkdir -p "build/$(CONFIG)/inc"
	cp src/mdb.h build/$(CONFIG)/inc/mdb.h

#
#   edi.o
#
DEPS_23 += build/$(CONFIG)/inc/me.h
DEPS_23 += build/$(CONFIG)/inc/edi.h
DEPS_23 += build/$(CONFIG)/inc/pcre.h
DEPS_23 += build/$(CONFIG)/inc/http.h

build/$(CONFIG)/obj/edi.o: \
    src/edi.c $(DEPS_23)
	@echo '   [Compile] build/$(CONFIG)/obj/edi.o'
	$(CC) -c -o build/$(CONFIG)/obj/edi.o $(CFLAGS) $(DFLAGS) "-Ibuild/$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/edi.c

#
#   espAbbrev.o
#
DEPS_24 += build/$(CONFIG)/inc/me.h
DEPS_24 += build/$(CONFIG)/inc/esp.h
DEPS_24 += build/$(CONFIG)/inc/appweb.h
DEPS_24 += build/$(CONFIG)/inc/edi.h

build/$(CONFIG)/obj/espAbbrev.o: \
    src/espAbbrev.c $(DEPS_24)
	@echo '   [Compile] build/$(CONFIG)/obj/espAbbrev.o'
	$(CC) -c -o build/$(CONFIG)/obj/espAbbrev.o $(CFLAGS) $(DFLAGS) "-Ibuild/$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/espAbbrev.c

#
#   espConfig.o
#
DEPS_25 += build/$(CONFIG)/inc/me.h
DEPS_25 += build/$(CONFIG)/inc/esp.h

build/$(CONFIG)/obj/espConfig.o: \
    src/espConfig.c $(DEPS_25)
	@echo '   [Compile] build/$(CONFIG)/obj/espConfig.o'
	$(CC) -c -o build/$(CONFIG)/obj/espConfig.o $(CFLAGS) $(DFLAGS) "-Ibuild/$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/espConfig.c

#
#   espFramework.o
#
DEPS_26 += build/$(CONFIG)/inc/me.h
DEPS_26 += build/$(CONFIG)/inc/esp.h

build/$(CONFIG)/obj/espFramework.o: \
    src/espFramework.c $(DEPS_26)
	@echo '   [Compile] build/$(CONFIG)/obj/espFramework.o'
	$(CC) -c -o build/$(CONFIG)/obj/espFramework.o $(CFLAGS) $(DFLAGS) "-Ibuild/$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/espFramework.c

#
#   espHandler.o
#
DEPS_27 += build/$(CONFIG)/inc/me.h
DEPS_27 += build/$(CONFIG)/inc/esp.h

build/$(CONFIG)/obj/espHandler.o: \
    src/espHandler.c $(DEPS_27)
	@echo '   [Compile] build/$(CONFIG)/obj/espHandler.o'
	$(CC) -c -o build/$(CONFIG)/obj/espHandler.o $(CFLAGS) $(DFLAGS) "-Ibuild/$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/espHandler.c

#
#   espHtml.o
#
DEPS_28 += build/$(CONFIG)/inc/me.h
DEPS_28 += build/$(CONFIG)/inc/esp.h
DEPS_28 += build/$(CONFIG)/inc/edi.h

build/$(CONFIG)/obj/espHtml.o: \
    src/espHtml.c $(DEPS_28)
	@echo '   [Compile] build/$(CONFIG)/obj/espHtml.o'
	$(CC) -c -o build/$(CONFIG)/obj/espHtml.o $(CFLAGS) $(DFLAGS) "-Ibuild/$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/espHtml.c

#
#   espTemplate.o
#
DEPS_29 += build/$(CONFIG)/inc/me.h
DEPS_29 += build/$(CONFIG)/inc/esp.h

build/$(CONFIG)/obj/espTemplate.o: \
    src/espTemplate.c $(DEPS_29)
	@echo '   [Compile] build/$(CONFIG)/obj/espTemplate.o'
	$(CC) -c -o build/$(CONFIG)/obj/espTemplate.o $(CFLAGS) $(DFLAGS) "-Ibuild/$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/espTemplate.c

#
#   mdb.o
#
DEPS_30 += build/$(CONFIG)/inc/me.h
DEPS_30 += build/$(CONFIG)/inc/http.h
DEPS_30 += build/$(CONFIG)/inc/edi.h
DEPS_30 += build/$(CONFIG)/inc/mdb.h
DEPS_30 += build/$(CONFIG)/inc/pcre.h

build/$(CONFIG)/obj/mdb.o: \
    src/mdb.c $(DEPS_30)
	@echo '   [Compile] build/$(CONFIG)/obj/mdb.o'
	$(CC) -c -o build/$(CONFIG)/obj/mdb.o $(CFLAGS) $(DFLAGS) "-Ibuild/$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/mdb.c

#
#   sdb.o
#
DEPS_31 += build/$(CONFIG)/inc/me.h
DEPS_31 += build/$(CONFIG)/inc/http.h
DEPS_31 += build/$(CONFIG)/inc/edi.h

build/$(CONFIG)/obj/sdb.o: \
    src/sdb.c $(DEPS_31)
	@echo '   [Compile] build/$(CONFIG)/obj/sdb.o'
	$(CC) -c -o build/$(CONFIG)/obj/sdb.o $(CFLAGS) $(DFLAGS) "-Ibuild/$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/sdb.c

#
#   libmod_esp
#
DEPS_32 += build/$(CONFIG)/inc/mpr.h
DEPS_32 += build/$(CONFIG)/inc/me.h
DEPS_32 += build/$(CONFIG)/inc/osdep.h
DEPS_32 += build/$(CONFIG)/obj/mprLib.o
DEPS_32 += build/$(CONFIG)/bin/libmpr.out
DEPS_32 += build/$(CONFIG)/inc/pcre.h
DEPS_32 += build/$(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_32 += build/$(CONFIG)/bin/libpcre.out
endif
DEPS_32 += build/$(CONFIG)/inc/http.h
DEPS_32 += build/$(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_32 += build/$(CONFIG)/bin/libhttp.out
endif
DEPS_32 += build/$(CONFIG)/inc/appweb.h
DEPS_32 += build/$(CONFIG)/obj/appwebLib.o
ifeq ($(ME_COM_APPWEB),1)
    DEPS_32 += build/$(CONFIG)/bin/libappweb.out
endif
DEPS_32 += build/$(CONFIG)/inc/sqlite3.h
DEPS_32 += build/$(CONFIG)/obj/sqlite3.o
ifeq ($(ME_COM_SQLITE),1)
    DEPS_32 += build/$(CONFIG)/bin/libsql.out
endif
DEPS_32 += build/$(CONFIG)/inc/edi.h
DEPS_32 += build/$(CONFIG)/inc/esp.h
DEPS_32 += build/$(CONFIG)/inc/mdb.h
DEPS_32 += build/$(CONFIG)/obj/edi.o
DEPS_32 += build/$(CONFIG)/obj/espAbbrev.o
DEPS_32 += build/$(CONFIG)/obj/espConfig.o
DEPS_32 += build/$(CONFIG)/obj/espFramework.o
DEPS_32 += build/$(CONFIG)/obj/espHandler.o
DEPS_32 += build/$(CONFIG)/obj/espHtml.o
DEPS_32 += build/$(CONFIG)/obj/espTemplate.o
DEPS_32 += build/$(CONFIG)/obj/mdb.o
DEPS_32 += build/$(CONFIG)/obj/sdb.o

build/$(CONFIG)/bin/libmod_esp.out: $(DEPS_32)
	@echo '      [Link] build/$(CONFIG)/bin/libmod_esp.out'
	$(CC) -r -o build/$(CONFIG)/bin/libmod_esp.out $(LDFLAGS) $(LIBPATHS) "build/$(CONFIG)/obj/edi.o" "build/$(CONFIG)/obj/espAbbrev.o" "build/$(CONFIG)/obj/espConfig.o" "build/$(CONFIG)/obj/espFramework.o" "build/$(CONFIG)/obj/espHandler.o" "build/$(CONFIG)/obj/espHtml.o" "build/$(CONFIG)/obj/espTemplate.o" "build/$(CONFIG)/obj/mdb.o" "build/$(CONFIG)/obj/sdb.o" $(LIBS) 

#
#   esp.o
#
DEPS_33 += build/$(CONFIG)/inc/me.h
DEPS_33 += build/$(CONFIG)/inc/esp.h

build/$(CONFIG)/obj/esp.o: \
    src/esp.c $(DEPS_33)
	@echo '   [Compile] build/$(CONFIG)/obj/esp.o'
	$(CC) -c -o build/$(CONFIG)/obj/esp.o $(CFLAGS) $(DFLAGS) "-Ibuild/$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/esp.c

#
#   espcmd
#
DEPS_34 += build/$(CONFIG)/inc/mpr.h
DEPS_34 += build/$(CONFIG)/inc/me.h
DEPS_34 += build/$(CONFIG)/inc/osdep.h
DEPS_34 += build/$(CONFIG)/obj/mprLib.o
DEPS_34 += build/$(CONFIG)/bin/libmpr.out
DEPS_34 += build/$(CONFIG)/inc/pcre.h
DEPS_34 += build/$(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_34 += build/$(CONFIG)/bin/libpcre.out
endif
DEPS_34 += build/$(CONFIG)/inc/http.h
DEPS_34 += build/$(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_34 += build/$(CONFIG)/bin/libhttp.out
endif
DEPS_34 += build/$(CONFIG)/inc/appweb.h
DEPS_34 += build/$(CONFIG)/obj/appwebLib.o
ifeq ($(ME_COM_APPWEB),1)
    DEPS_34 += build/$(CONFIG)/bin/libappweb.out
endif
DEPS_34 += build/$(CONFIG)/inc/sqlite3.h
DEPS_34 += build/$(CONFIG)/obj/sqlite3.o
ifeq ($(ME_COM_SQLITE),1)
    DEPS_34 += build/$(CONFIG)/bin/libsql.out
endif
DEPS_34 += build/$(CONFIG)/inc/edi.h
DEPS_34 += build/$(CONFIG)/inc/esp.h
DEPS_34 += build/$(CONFIG)/inc/mdb.h
DEPS_34 += build/$(CONFIG)/obj/edi.o
DEPS_34 += build/$(CONFIG)/obj/espAbbrev.o
DEPS_34 += build/$(CONFIG)/obj/espConfig.o
DEPS_34 += build/$(CONFIG)/obj/espFramework.o
DEPS_34 += build/$(CONFIG)/obj/espHandler.o
DEPS_34 += build/$(CONFIG)/obj/espHtml.o
DEPS_34 += build/$(CONFIG)/obj/espTemplate.o
DEPS_34 += build/$(CONFIG)/obj/mdb.o
DEPS_34 += build/$(CONFIG)/obj/sdb.o
DEPS_34 += build/$(CONFIG)/bin/libmod_esp.out
DEPS_34 += build/$(CONFIG)/obj/esp.o

build/$(CONFIG)/bin/esp.out: $(DEPS_34)
	@echo '      [Link] build/$(CONFIG)/bin/esp.out'
	$(CC) -o build/$(CONFIG)/bin/esp.out $(LDFLAGS) $(LIBPATHS) "build/$(CONFIG)/obj/esp.o" $(LIBS) -Wl,-r 


#
#   http-ca-crt
#
DEPS_35 += src/paks/http/ca.crt

build/$(CONFIG)/bin/ca.crt: $(DEPS_35)
	@echo '      [Copy] build/$(CONFIG)/bin/ca.crt'
	mkdir -p "build/$(CONFIG)/bin"
	cp src/paks/http/ca.crt build/$(CONFIG)/bin/ca.crt

#
#   est.h
#
build/$(CONFIG)/inc/est.h: $(DEPS_36)
	@echo '      [Copy] build/$(CONFIG)/inc/est.h'
	mkdir -p "build/$(CONFIG)/inc"
	cp src/paks/est/est.h build/$(CONFIG)/inc/est.h

#
#   estLib.o
#
DEPS_37 += build/$(CONFIG)/inc/me.h
DEPS_37 += build/$(CONFIG)/inc/est.h
DEPS_37 += build/$(CONFIG)/inc/osdep.h

build/$(CONFIG)/obj/estLib.o: \
    src/paks/est/estLib.c $(DEPS_37)
	@echo '   [Compile] build/$(CONFIG)/obj/estLib.o'
	$(CC) -c -o build/$(CONFIG)/obj/estLib.o $(CFLAGS) $(DFLAGS) "-Ibuild/$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/paks/est/estLib.c

ifeq ($(ME_COM_EST),1)
#
#   libest
#
DEPS_38 += build/$(CONFIG)/inc/est.h
DEPS_38 += build/$(CONFIG)/inc/me.h
DEPS_38 += build/$(CONFIG)/inc/osdep.h
DEPS_38 += build/$(CONFIG)/obj/estLib.o

build/$(CONFIG)/bin/libest.out: $(DEPS_38)
	@echo '      [Link] build/$(CONFIG)/bin/libest.out'
	$(CC) -r -o build/$(CONFIG)/bin/libest.out $(LDFLAGS) $(LIBPATHS) "build/$(CONFIG)/obj/estLib.o" $(LIBS) 
endif

#
#   mprSsl.o
#
DEPS_39 += build/$(CONFIG)/inc/me.h
DEPS_39 += build/$(CONFIG)/inc/mpr.h

build/$(CONFIG)/obj/mprSsl.o: \
    src/paks/mpr/mprSsl.c $(DEPS_39)
	@echo '   [Compile] build/$(CONFIG)/obj/mprSsl.o'
	$(CC) -c -o build/$(CONFIG)/obj/mprSsl.o $(CFLAGS) $(DFLAGS) "-Ibuild/$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" "-I$(ME_COM_MATRIXSSL_PATH)" "-I$(ME_COM_MATRIXSSL_PATH)/matrixssl" "-I$(ME_COM_NANOSSL_PATH)/src" src/paks/mpr/mprSsl.c

#
#   libmprssl
#
DEPS_40 += build/$(CONFIG)/inc/mpr.h
DEPS_40 += build/$(CONFIG)/inc/me.h
DEPS_40 += build/$(CONFIG)/inc/osdep.h
DEPS_40 += build/$(CONFIG)/obj/mprLib.o
DEPS_40 += build/$(CONFIG)/bin/libmpr.out
DEPS_40 += build/$(CONFIG)/inc/est.h
DEPS_40 += build/$(CONFIG)/obj/estLib.o
ifeq ($(ME_COM_EST),1)
    DEPS_40 += build/$(CONFIG)/bin/libest.out
endif
DEPS_40 += build/$(CONFIG)/obj/mprSsl.o

ifeq ($(ME_COM_OPENSSL),1)
    LIBS_40 += -lssl
    LIBPATHS_40 += -L$(ME_COM_OPENSSL_PATH)
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_40 += -lcrypto
    LIBPATHS_40 += -L$(ME_COM_OPENSSL_PATH)
endif
ifeq ($(ME_COM_MATRIXSSL),1)
    LIBS_40 += -lmatrixssl
    LIBPATHS_40 += -L$(ME_COM_MATRIXSSL_PATH)
endif
ifeq ($(ME_COM_NANOSSL),1)
    LIBS_40 += -lssls
    LIBPATHS_40 += -L$(ME_COM_NANOSSL_PATH)/bin
endif

build/$(CONFIG)/bin/libmprssl.out: $(DEPS_40)
	@echo '      [Link] build/$(CONFIG)/bin/libmprssl.out'
	$(CC) -r -o build/$(CONFIG)/bin/libmprssl.out $(LDFLAGS) $(LIBPATHS)    "build/$(CONFIG)/obj/mprSsl.o" $(LIBPATHS_40) $(LIBS_40) $(LIBS_40) $(LIBS) 

#
#   manager.o
#
DEPS_41 += build/$(CONFIG)/inc/me.h
DEPS_41 += build/$(CONFIG)/inc/mpr.h

build/$(CONFIG)/obj/manager.o: \
    src/paks/mpr/manager.c $(DEPS_41)
	@echo '   [Compile] build/$(CONFIG)/obj/manager.o'
	$(CC) -c -o build/$(CONFIG)/obj/manager.o $(CFLAGS) $(DFLAGS) "-Ibuild/$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/paks/mpr/manager.c

#
#   manager
#
DEPS_42 += build/$(CONFIG)/inc/mpr.h
DEPS_42 += build/$(CONFIG)/inc/me.h
DEPS_42 += build/$(CONFIG)/inc/osdep.h
DEPS_42 += build/$(CONFIG)/obj/mprLib.o
DEPS_42 += build/$(CONFIG)/bin/libmpr.out
DEPS_42 += build/$(CONFIG)/obj/manager.o

build/$(CONFIG)/bin/espman.out: $(DEPS_42)
	@echo '      [Link] build/$(CONFIG)/bin/espman.out'
	$(CC) -o build/$(CONFIG)/bin/espman.out $(LDFLAGS) $(LIBPATHS) "build/$(CONFIG)/obj/manager.o" $(LIBS) -Wl,-r 

#
#   sqlite.o
#
DEPS_43 += build/$(CONFIG)/inc/me.h
DEPS_43 += build/$(CONFIG)/inc/sqlite3.h

build/$(CONFIG)/obj/sqlite.o: \
    src/paks/sqlite/sqlite.c $(DEPS_43)
	@echo '   [Compile] build/$(CONFIG)/obj/sqlite.o'
	$(CC) -c -o build/$(CONFIG)/obj/sqlite.o $(CFLAGS) $(DFLAGS) "-Ibuild/$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/paks/sqlite/sqlite.c

ifeq ($(ME_COM_SQLITE),1)
#
#   sqliteshell
#
DEPS_44 += build/$(CONFIG)/inc/sqlite3.h
DEPS_44 += build/$(CONFIG)/inc/me.h
DEPS_44 += build/$(CONFIG)/obj/sqlite3.o
DEPS_44 += build/$(CONFIG)/bin/libsql.out
DEPS_44 += build/$(CONFIG)/obj/sqlite.o

build/$(CONFIG)/bin/sqlite.out: $(DEPS_44)
	@echo '      [Link] build/$(CONFIG)/bin/sqlite.out'
	$(CC) -o build/$(CONFIG)/bin/sqlite.out $(LDFLAGS) $(LIBPATHS) "build/$(CONFIG)/obj/sqlite.o" $(LIBS) -Wl,-r 
endif

#
#   stop
#
stop: $(DEPS_45)

#
#   installBinary
#
installBinary: $(DEPS_46)

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

#
#   version
#
version: $(DEPS_50)
	echo 5.1.0

