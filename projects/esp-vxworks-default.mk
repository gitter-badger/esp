#
#   esp-vxworks-default.mk -- Makefile to build Embedthis ESP for vxworks
#

NAME                  := esp
VERSION               := 5.2.0
PROFILE               ?= default
ARCH                  ?= $(shell echo $(WIND_HOST_TYPE) | sed 's/-.*$(ME_ROOT_PREFIX)/')
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
ME_COM_MDB            ?= 1
ME_COM_OPENSSL        ?= 0
ME_COM_OSDEP          ?= 1
ME_COM_PCRE           ?= 1
ME_COM_SQLITE         ?= 1
ME_COM_SSL            ?= 1
ME_COM_WINSDK         ?= 1

ifeq ($(ME_COM_EST),1)
    ME_COM_SSL := 1
endif
ifeq ($(ME_COM_OPENSSL),1)
    ME_COM_SSL := 1
endif

export WIND_HOME      ?= $(WIND_BASE)/..
export PATH           := $(WIND_GNU_PATH)/$(WIND_HOST_TYPE)/bin:$(PATH)

CFLAGS                += -fno-builtin -fno-defer-pop -fvolatile -w
DFLAGS                += -DVXWORKS -DRW_MULTI_THREAD -D_GNU_TOOL -DCPU=PENTIUM $(patsubst %,-D%,$(filter ME_%,$(MAKEFLAGS))) -DME_COM_APPWEB=$(ME_COM_APPWEB) -DME_COM_CGI=$(ME_COM_CGI) -DME_COM_DIR=$(ME_COM_DIR) -DME_COM_EST=$(ME_COM_EST) -DME_COM_HTTP=$(ME_COM_HTTP) -DME_COM_MDB=$(ME_COM_MDB) -DME_COM_OPENSSL=$(ME_COM_OPENSSL) -DME_COM_OSDEP=$(ME_COM_OSDEP) -DME_COM_PCRE=$(ME_COM_PCRE) -DME_COM_SQLITE=$(ME_COM_SQLITE) -DME_COM_SSL=$(ME_COM_SSL) -DME_COM_WINSDK=$(ME_COM_WINSDK) 
IFLAGS                += "-I$(BUILD)/inc -I$(WIND_BASE)/target/h -I$(WIND_BASE)/target/h/wrn/coreip"
LDFLAGS               += '-Wl,-r'
LIBPATHS              += -L$(BUILD)/bin
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


TARGETS               += $(BUILD)/bin/esp.conf
TARGETS               += $(BUILD)/bin/ca.crt
ifeq ($(ME_COM_APPWEB),1)
    TARGETS           += $(BUILD)/bin/libappweb.out
endif
ifeq ($(ME_COM_EST),1)
    TARGETS           += $(BUILD)/bin/libest.out
endif
TARGETS               += $(BUILD)/bin/libmod_esp.out
TARGETS               += $(BUILD)/bin/libmprssl.out
TARGETS               += $(BUILD)/bin/espman.out

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
	@echo "$(MAKEFLAGS)" >$(BUILD)/.makeflags

clean:
	rm -f "$(BUILD)/obj/appwebLib.o"
	rm -f "$(BUILD)/obj/edi.o"
	rm -f "$(BUILD)/obj/espAbbrev.o"
	rm -f "$(BUILD)/obj/espConfig.o"
	rm -f "$(BUILD)/obj/espFramework.o"
	rm -f "$(BUILD)/obj/espHandler.o"
	rm -f "$(BUILD)/obj/espHtml.o"
	rm -f "$(BUILD)/obj/espTemplate.o"
	rm -f "$(BUILD)/obj/estLib.o"
	rm -f "$(BUILD)/obj/httpLib.o"
	rm -f "$(BUILD)/obj/manager.o"
	rm -f "$(BUILD)/obj/mdb.o"
	rm -f "$(BUILD)/obj/mprLib.o"
	rm -f "$(BUILD)/obj/mprSsl.o"
	rm -f "$(BUILD)/obj/pcre.o"
	rm -f "$(BUILD)/obj/sdb.o"
	rm -f "$(BUILD)/obj/sqlite3.o"
	rm -f "$(BUILD)/bin/esp.conf"
	rm -f "$(BUILD)/bin/ca.crt"
	rm -f "$(BUILD)/bin/libappweb.out"
	rm -f "$(BUILD)/bin/libest.out"
	rm -f "$(BUILD)/bin/libhttp.out"
	rm -f "$(BUILD)/bin/libmod_esp.out"
	rm -f "$(BUILD)/bin/libmpr.out"
	rm -f "$(BUILD)/bin/libmprssl.out"
	rm -f "$(BUILD)/bin/libpcre.out"
	rm -f "$(BUILD)/bin/libsql.out"
	rm -f "$(BUILD)/bin/espman.out"

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
	$(CC) -c -o $(BUILD)/obj/appwebLib.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/paks/appweb/appwebLib.c

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
	$(CC) -c -o $(BUILD)/obj/edi.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/edi.c

#
#   esp.h
#

src/esp.h: $(DEPS_16)

#
#   espAbbrev.o
#
DEPS_17 += src/esp.h

$(BUILD)/obj/espAbbrev.o: \
    src/espAbbrev.c $(DEPS_17)
	@echo '   [Compile] $(BUILD)/obj/espAbbrev.o'
	$(CC) -c -o $(BUILD)/obj/espAbbrev.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/espAbbrev.c

#
#   espConfig.o
#
DEPS_18 += src/esp.h

$(BUILD)/obj/espConfig.o: \
    src/espConfig.c $(DEPS_18)
	@echo '   [Compile] $(BUILD)/obj/espConfig.o'
	$(CC) -c -o $(BUILD)/obj/espConfig.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/espConfig.c

#
#   espFramework.o
#
DEPS_19 += src/esp.h

$(BUILD)/obj/espFramework.o: \
    src/espFramework.c $(DEPS_19)
	@echo '   [Compile] $(BUILD)/obj/espFramework.o'
	$(CC) -c -o $(BUILD)/obj/espFramework.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/espFramework.c

#
#   espHandler.o
#
DEPS_20 += src/esp.h

$(BUILD)/obj/espHandler.o: \
    src/espHandler.c $(DEPS_20)
	@echo '   [Compile] $(BUILD)/obj/espHandler.o'
	$(CC) -c -o $(BUILD)/obj/espHandler.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/espHandler.c

#
#   espHtml.o
#
DEPS_21 += src/esp.h
DEPS_21 += src/edi.h

$(BUILD)/obj/espHtml.o: \
    src/espHtml.c $(DEPS_21)
	@echo '   [Compile] $(BUILD)/obj/espHtml.o'
	$(CC) -c -o $(BUILD)/obj/espHtml.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/espHtml.c

#
#   espTemplate.o
#
DEPS_22 += src/esp.h

$(BUILD)/obj/espTemplate.o: \
    src/espTemplate.c $(DEPS_22)
	@echo '   [Compile] $(BUILD)/obj/espTemplate.o'
	$(CC) -c -o $(BUILD)/obj/espTemplate.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/espTemplate.c

#
#   est.h
#

src/paks/est/est.h: $(DEPS_23)

#
#   estLib.o
#
DEPS_24 += src/paks/est/est.h

$(BUILD)/obj/estLib.o: \
    src/paks/est/estLib.c $(DEPS_24)
	@echo '   [Compile] $(BUILD)/obj/estLib.o'
	$(CC) -c -o $(BUILD)/obj/estLib.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/paks/est/estLib.c

#
#   http.h
#

src/paks/http/http.h: $(DEPS_25)

#
#   httpLib.o
#
DEPS_26 += src/paks/http/http.h

$(BUILD)/obj/httpLib.o: \
    src/paks/http/httpLib.c $(DEPS_26)
	@echo '   [Compile] $(BUILD)/obj/httpLib.o'
	$(CC) -c -o $(BUILD)/obj/httpLib.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/paks/http/httpLib.c

#
#   mpr.h
#

src/paks/mpr/mpr.h: $(DEPS_27)

#
#   manager.o
#
DEPS_28 += src/paks/mpr/mpr.h

$(BUILD)/obj/manager.o: \
    src/paks/mpr/manager.c $(DEPS_28)
	@echo '   [Compile] $(BUILD)/obj/manager.o'
	$(CC) -c -o $(BUILD)/obj/manager.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/paks/mpr/manager.c

#
#   mdb.h
#

src/mdb.h: $(DEPS_29)

#
#   mdb.o
#
DEPS_30 += $(BUILD)/inc/http.h
DEPS_30 += src/edi.h
DEPS_30 += src/mdb.h
DEPS_30 += $(BUILD)/inc/pcre.h

$(BUILD)/obj/mdb.o: \
    src/mdb.c $(DEPS_30)
	@echo '   [Compile] $(BUILD)/obj/mdb.o'
	$(CC) -c -o $(BUILD)/obj/mdb.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/mdb.c

#
#   mprLib.o
#
DEPS_31 += src/paks/mpr/mpr.h

$(BUILD)/obj/mprLib.o: \
    src/paks/mpr/mprLib.c $(DEPS_31)
	@echo '   [Compile] $(BUILD)/obj/mprLib.o'
	$(CC) -c -o $(BUILD)/obj/mprLib.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/paks/mpr/mprLib.c

#
#   mprSsl.o
#
DEPS_32 += $(BUILD)/inc/me.h
DEPS_32 += src/paks/mpr/mpr.h

$(BUILD)/obj/mprSsl.o: \
    src/paks/mpr/mprSsl.c $(DEPS_32)
	@echo '   [Compile] $(BUILD)/obj/mprSsl.o'
	$(CC) -c -o $(BUILD)/obj/mprSsl.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" src/paks/mpr/mprSsl.c

#
#   pcre.h
#

src/paks/pcre/pcre.h: $(DEPS_33)

#
#   pcre.o
#
DEPS_34 += $(BUILD)/inc/me.h
DEPS_34 += src/paks/pcre/pcre.h

$(BUILD)/obj/pcre.o: \
    src/paks/pcre/pcre.c $(DEPS_34)
	@echo '   [Compile] $(BUILD)/obj/pcre.o'
	$(CC) -c -o $(BUILD)/obj/pcre.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/paks/pcre/pcre.c

#
#   sdb.o
#
DEPS_35 += $(BUILD)/inc/http.h
DEPS_35 += src/edi.h

$(BUILD)/obj/sdb.o: \
    src/sdb.c $(DEPS_35)
	@echo '   [Compile] $(BUILD)/obj/sdb.o'
	$(CC) -c -o $(BUILD)/obj/sdb.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/sdb.c

#
#   sqlite3.h
#

src/paks/sqlite/sqlite3.h: $(DEPS_36)

#
#   sqlite3.o
#
DEPS_37 += $(BUILD)/inc/me.h
DEPS_37 += src/paks/sqlite/sqlite3.h

$(BUILD)/obj/sqlite3.o: \
    src/paks/sqlite/sqlite3.c $(DEPS_37)
	@echo '   [Compile] $(BUILD)/obj/sqlite3.o'
	$(CC) -c -o $(BUILD)/obj/sqlite3.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/paks/sqlite/sqlite3.c

#
#   esp.conf
#
DEPS_38 += src/esp.conf

$(BUILD)/bin/esp.conf: $(DEPS_38)
	@echo '      [Copy] $(BUILD)/bin/esp.conf'
	mkdir -p "$(BUILD)/bin"
	cp src/esp.conf $(BUILD)/bin/esp.conf

#
#   http-ca-crt
#
DEPS_39 += src/paks/http/ca.crt

$(BUILD)/bin/ca.crt: $(DEPS_39)
	@echo '      [Copy] $(BUILD)/bin/ca.crt'
	mkdir -p "$(BUILD)/bin"
	cp src/paks/http/ca.crt $(BUILD)/bin/ca.crt

#
#   libmpr
#
DEPS_40 += $(BUILD)/inc/osdep.h
DEPS_40 += $(BUILD)/inc/mpr.h
DEPS_40 += $(BUILD)/obj/mprLib.o

$(BUILD)/bin/libmpr.out: $(DEPS_40)
	@echo '      [Link] $(BUILD)/bin/libmpr.out'
	$(CC) -r -o $(BUILD)/bin/libmpr.out $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/mprLib.o" $(LIBS) 

ifeq ($(ME_COM_PCRE),1)
#
#   libpcre
#
DEPS_41 += $(BUILD)/inc/pcre.h
DEPS_41 += $(BUILD)/obj/pcre.o

$(BUILD)/bin/libpcre.out: $(DEPS_41)
	@echo '      [Link] $(BUILD)/bin/libpcre.out'
	$(CC) -r -o $(BUILD)/bin/libpcre.out $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/pcre.o" $(LIBS) 
endif

ifeq ($(ME_COM_HTTP),1)
#
#   libhttp
#
DEPS_42 += $(BUILD)/bin/libmpr.out
ifeq ($(ME_COM_PCRE),1)
    DEPS_42 += $(BUILD)/bin/libpcre.out
endif
DEPS_42 += $(BUILD)/inc/http.h
DEPS_42 += $(BUILD)/obj/httpLib.o

$(BUILD)/bin/libhttp.out: $(DEPS_42)
	@echo '      [Link] $(BUILD)/bin/libhttp.out'
	$(CC) -r -o $(BUILD)/bin/libhttp.out $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/httpLib.o" $(LIBS) 
endif

ifeq ($(ME_COM_APPWEB),1)
#
#   libappweb
#
ifeq ($(ME_COM_HTTP),1)
    DEPS_43 += $(BUILD)/bin/libhttp.out
endif
ifeq ($(ME_COM_PCRE),1)
    DEPS_43 += $(BUILD)/bin/libpcre.out
endif
DEPS_43 += $(BUILD)/bin/libmpr.out
DEPS_43 += $(BUILD)/inc/appweb.h
DEPS_43 += $(BUILD)/obj/appwebLib.o

$(BUILD)/bin/libappweb.out: $(DEPS_43)
	@echo '      [Link] $(BUILD)/bin/libappweb.out'
	$(CC) -r -o $(BUILD)/bin/libappweb.out $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/appwebLib.o" $(LIBS) 
endif

ifeq ($(ME_COM_EST),1)
#
#   libest
#
DEPS_44 += $(BUILD)/inc/osdep.h
DEPS_44 += $(BUILD)/inc/est.h
DEPS_44 += $(BUILD)/obj/estLib.o

$(BUILD)/bin/libest.out: $(DEPS_44)
	@echo '      [Link] $(BUILD)/bin/libest.out'
	$(CC) -r -o $(BUILD)/bin/libest.out $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/estLib.o" $(LIBS) 
endif

ifeq ($(ME_COM_SQLITE),1)
#
#   libsql
#
DEPS_45 += $(BUILD)/inc/sqlite3.h
DEPS_45 += $(BUILD)/obj/sqlite3.o

$(BUILD)/bin/libsql.out: $(DEPS_45)
	@echo '      [Link] $(BUILD)/bin/libsql.out'
	$(CC) -r -o $(BUILD)/bin/libsql.out $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/sqlite3.o" $(LIBS) 
endif

#
#   libmod_esp
#
ifeq ($(ME_COM_APPWEB),1)
    DEPS_46 += $(BUILD)/bin/libappweb.out
endif
ifeq ($(ME_COM_SQLITE),1)
    DEPS_46 += $(BUILD)/bin/libsql.out
endif
DEPS_46 += $(BUILD)/inc/edi.h
DEPS_46 += $(BUILD)/inc/esp.h
DEPS_46 += $(BUILD)/inc/mdb.h
DEPS_46 += $(BUILD)/obj/edi.o
DEPS_46 += $(BUILD)/obj/espAbbrev.o
DEPS_46 += $(BUILD)/obj/espConfig.o
DEPS_46 += $(BUILD)/obj/espFramework.o
DEPS_46 += $(BUILD)/obj/espHandler.o
DEPS_46 += $(BUILD)/obj/espHtml.o
DEPS_46 += $(BUILD)/obj/espTemplate.o
DEPS_46 += $(BUILD)/obj/mdb.o
DEPS_46 += $(BUILD)/obj/sdb.o

$(BUILD)/bin/libmod_esp.out: $(DEPS_46)
	@echo '      [Link] $(BUILD)/bin/libmod_esp.out'
	$(CC) -r -o $(BUILD)/bin/libmod_esp.out $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/edi.o" "$(BUILD)/obj/espAbbrev.o" "$(BUILD)/obj/espConfig.o" "$(BUILD)/obj/espFramework.o" "$(BUILD)/obj/espHandler.o" "$(BUILD)/obj/espHtml.o" "$(BUILD)/obj/espTemplate.o" "$(BUILD)/obj/mdb.o" "$(BUILD)/obj/sdb.o" $(LIBS) 

#
#   libmprssl
#
DEPS_47 += $(BUILD)/bin/libmpr.out
ifeq ($(ME_COM_EST),1)
    DEPS_47 += $(BUILD)/bin/libest.out
endif
DEPS_47 += $(BUILD)/obj/mprSsl.o

ifeq ($(ME_COM_OPENSSL),1)
    LIBS_47 += -lssl
    LIBPATHS_47 += -L$(ME_COM_OPENSSL_PATH)
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_47 += -lcrypto
    LIBPATHS_47 += -L$(ME_COM_OPENSSL_PATH)
endif

$(BUILD)/bin/libmprssl.out: $(DEPS_47)
	@echo '      [Link] $(BUILD)/bin/libmprssl.out'
	$(CC) -r -o $(BUILD)/bin/libmprssl.out $(LDFLAGS) $(LIBPATHS)  "$(BUILD)/obj/mprSsl.o" $(LIBPATHS_47) $(LIBS_47) $(LIBS_47) $(LIBS) 

#
#   manager
#
DEPS_48 += $(BUILD)/bin/libmpr.out
DEPS_48 += $(BUILD)/obj/manager.o

$(BUILD)/bin/espman.out: $(DEPS_48)
	@echo '      [Link] $(BUILD)/bin/espman.out'
	$(CC) -o $(BUILD)/bin/espman.out $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/manager.o" $(LIBS) -Wl,-r 


#
#   installBinary
#

installBinary: $(DEPS_49)


#
#   install
#
DEPS_50 += stop
DEPS_50 += installBinary
DEPS_50 += start

install: $(DEPS_50)

#
#   uninstall
#
DEPS_51 += stop

uninstall: $(DEPS_51)

#
#   version
#

version: $(DEPS_52)
	echo 5.2.0

