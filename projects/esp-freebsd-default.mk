#
#   esp-freebsd-default.mk -- Makefile to build Embedthis ESP for freebsd
#

NAME                  := esp
VERSION               := 5.2.0
PROFILE               ?= default
ARCH                  ?= $(shell uname -m | sed 's/i.86/x86/;s/x86_64/x64/;s/arm.*/arm/;s/mips.*/mips/')
CC_ARCH               ?= $(shell echo $(ARCH) | sed 's/x86/i686/;s/x64/x86_64/')
OS                    ?= freebsd
CC                    ?= gcc
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

CFLAGS                += -fPIC -w
DFLAGS                += -D_REENTRANT -DPIC $(patsubst %,-D%,$(filter ME_%,$(MAKEFLAGS))) -DME_COM_APPWEB=$(ME_COM_APPWEB) -DME_COM_CGI=$(ME_COM_CGI) -DME_COM_DIR=$(ME_COM_DIR) -DME_COM_EST=$(ME_COM_EST) -DME_COM_HTTP=$(ME_COM_HTTP) -DME_COM_MDB=$(ME_COM_MDB) -DME_COM_OPENSSL=$(ME_COM_OPENSSL) -DME_COM_OSDEP=$(ME_COM_OSDEP) -DME_COM_PCRE=$(ME_COM_PCRE) -DME_COM_SQLITE=$(ME_COM_SQLITE) -DME_COM_SSL=$(ME_COM_SSL) -DME_COM_VXWORKS=$(ME_COM_VXWORKS) -DME_COM_WINSDK=$(ME_COM_WINSDK) 
IFLAGS                += "-I$(BUILD)/inc"
LDFLAGS               += 
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


TARGETS               += $(BUILD)/bin/esp.conf
TARGETS               += $(BUILD)/bin/ca.crt
ifeq ($(ME_COM_APPWEB),1)
    TARGETS           += $(BUILD)/bin/libappweb.so
endif
ifeq ($(ME_COM_EST),1)
    TARGETS           += $(BUILD)/bin/libest.so
endif
TARGETS               += $(BUILD)/bin/libmod_esp.so
TARGETS               += $(BUILD)/bin/libmprssl.so
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
	@[ ! -f $(BUILD)/inc/me.h ] && cp projects/esp-freebsd-default-me.h $(BUILD)/inc/me.h ; true
	@if ! diff $(BUILD)/inc/me.h projects/esp-freebsd-default-me.h >/dev/null ; then\
		cp projects/esp-freebsd-default-me.h $(BUILD)/inc/me.h  ; \
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
	rm -f "$(BUILD)/bin/libappweb.so"
	rm -f "$(BUILD)/bin/libest.so"
	rm -f "$(BUILD)/bin/libhttp.so"
	rm -f "$(BUILD)/bin/libmod_esp.so"
	rm -f "$(BUILD)/bin/libmpr.so"
	rm -f "$(BUILD)/bin/libmprssl.so"
	rm -f "$(BUILD)/bin/libpcre.so"
	rm -f "$(BUILD)/bin/libsql.so"
	rm -f "$(BUILD)/bin/espman"

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
	$(CC) -c -o $(BUILD)/obj/appwebLib.o $(LDFLAGS) $(CFLAGS) $(DFLAGS) $(IFLAGS) src/paks/appweb/appwebLib.c

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
	$(CC) -c -o $(BUILD)/obj/edi.o $(LDFLAGS) $(CFLAGS) $(DFLAGS) $(IFLAGS) src/edi.c

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
	$(CC) -c -o $(BUILD)/obj/espAbbrev.o $(LDFLAGS) $(CFLAGS) $(DFLAGS) $(IFLAGS) src/espAbbrev.c

#
#   espConfig.o
#
DEPS_18 += src/esp.h

$(BUILD)/obj/espConfig.o: \
    src/espConfig.c $(DEPS_18)
	@echo '   [Compile] $(BUILD)/obj/espConfig.o'
	$(CC) -c -o $(BUILD)/obj/espConfig.o $(LDFLAGS) $(CFLAGS) $(DFLAGS) $(IFLAGS) src/espConfig.c

#
#   espFramework.o
#
DEPS_19 += src/esp.h

$(BUILD)/obj/espFramework.o: \
    src/espFramework.c $(DEPS_19)
	@echo '   [Compile] $(BUILD)/obj/espFramework.o'
	$(CC) -c -o $(BUILD)/obj/espFramework.o $(LDFLAGS) $(CFLAGS) $(DFLAGS) $(IFLAGS) src/espFramework.c

#
#   espHandler.o
#
DEPS_20 += src/esp.h

$(BUILD)/obj/espHandler.o: \
    src/espHandler.c $(DEPS_20)
	@echo '   [Compile] $(BUILD)/obj/espHandler.o'
	$(CC) -c -o $(BUILD)/obj/espHandler.o $(LDFLAGS) $(CFLAGS) $(DFLAGS) $(IFLAGS) src/espHandler.c

#
#   espHtml.o
#
DEPS_21 += src/esp.h
DEPS_21 += src/edi.h

$(BUILD)/obj/espHtml.o: \
    src/espHtml.c $(DEPS_21)
	@echo '   [Compile] $(BUILD)/obj/espHtml.o'
	$(CC) -c -o $(BUILD)/obj/espHtml.o $(LDFLAGS) $(CFLAGS) $(DFLAGS) $(IFLAGS) src/espHtml.c

#
#   espTemplate.o
#
DEPS_22 += src/esp.h

$(BUILD)/obj/espTemplate.o: \
    src/espTemplate.c $(DEPS_22)
	@echo '   [Compile] $(BUILD)/obj/espTemplate.o'
	$(CC) -c -o $(BUILD)/obj/espTemplate.o $(LDFLAGS) $(CFLAGS) $(DFLAGS) $(IFLAGS) src/espTemplate.c

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
	$(CC) -c -o $(BUILD)/obj/estLib.o $(LDFLAGS) $(CFLAGS) $(DFLAGS) $(IFLAGS) src/paks/est/estLib.c

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
	$(CC) -c -o $(BUILD)/obj/httpLib.o $(LDFLAGS) $(CFLAGS) $(DFLAGS) $(IFLAGS) src/paks/http/httpLib.c

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
	$(CC) -c -o $(BUILD)/obj/manager.o $(LDFLAGS) $(CFLAGS) $(DFLAGS) $(IFLAGS) src/paks/mpr/manager.c

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
	$(CC) -c -o $(BUILD)/obj/mdb.o $(LDFLAGS) $(CFLAGS) $(DFLAGS) $(IFLAGS) src/mdb.c

#
#   mprLib.o
#
DEPS_31 += src/paks/mpr/mpr.h

$(BUILD)/obj/mprLib.o: \
    src/paks/mpr/mprLib.c $(DEPS_31)
	@echo '   [Compile] $(BUILD)/obj/mprLib.o'
	$(CC) -c -o $(BUILD)/obj/mprLib.o $(LDFLAGS) $(CFLAGS) $(DFLAGS) $(IFLAGS) src/paks/mpr/mprLib.c

#
#   mprSsl.o
#
DEPS_32 += $(BUILD)/inc/me.h
DEPS_32 += src/paks/mpr/mpr.h

$(BUILD)/obj/mprSsl.o: \
    src/paks/mpr/mprSsl.c $(DEPS_32)
	@echo '   [Compile] $(BUILD)/obj/mprSsl.o'
	$(CC) -c -o $(BUILD)/obj/mprSsl.o $(LDFLAGS) $(CFLAGS) $(DFLAGS) $(IFLAGS) "-I$(ME_COM_OPENSSL_PATH)/include" src/paks/mpr/mprSsl.c

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
	$(CC) -c -o $(BUILD)/obj/pcre.o $(LDFLAGS) $(CFLAGS) $(DFLAGS) $(IFLAGS) src/paks/pcre/pcre.c

#
#   sdb.o
#
DEPS_35 += $(BUILD)/inc/http.h
DEPS_35 += src/edi.h

$(BUILD)/obj/sdb.o: \
    src/sdb.c $(DEPS_35)
	@echo '   [Compile] $(BUILD)/obj/sdb.o'
	$(CC) -c -o $(BUILD)/obj/sdb.o $(LDFLAGS) $(CFLAGS) $(DFLAGS) $(IFLAGS) src/sdb.c

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
	$(CC) -c -o $(BUILD)/obj/sqlite3.o $(LDFLAGS) $(CFLAGS) $(DFLAGS) $(IFLAGS) src/paks/sqlite/sqlite3.c

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

$(BUILD)/bin/libmpr.so: $(DEPS_40)
	@echo '      [Link] $(BUILD)/bin/libmpr.so'
	$(CC) -shared -o $(BUILD)/bin/libmpr.so $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/mprLib.o" $(LIBS) 

ifeq ($(ME_COM_PCRE),1)
#
#   libpcre
#
DEPS_41 += $(BUILD)/inc/pcre.h
DEPS_41 += $(BUILD)/obj/pcre.o

$(BUILD)/bin/libpcre.so: $(DEPS_41)
	@echo '      [Link] $(BUILD)/bin/libpcre.so'
	$(CC) -shared -o $(BUILD)/bin/libpcre.so $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/pcre.o" $(LIBS) 
endif

ifeq ($(ME_COM_HTTP),1)
#
#   libhttp
#
DEPS_42 += $(BUILD)/bin/libmpr.so
ifeq ($(ME_COM_PCRE),1)
    DEPS_42 += $(BUILD)/bin/libpcre.so
endif
DEPS_42 += $(BUILD)/inc/http.h
DEPS_42 += $(BUILD)/obj/httpLib.o

LIBS_42 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_42 += -lpcre
endif

$(BUILD)/bin/libhttp.so: $(DEPS_42)
	@echo '      [Link] $(BUILD)/bin/libhttp.so'
	$(CC) -shared -o $(BUILD)/bin/libhttp.so $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/httpLib.o" $(LIBPATHS_42) $(LIBS_42) $(LIBS_42) $(LIBS) 
endif

ifeq ($(ME_COM_APPWEB),1)
#
#   libappweb
#
ifeq ($(ME_COM_HTTP),1)
    DEPS_43 += $(BUILD)/bin/libhttp.so
endif
ifeq ($(ME_COM_PCRE),1)
    DEPS_43 += $(BUILD)/bin/libpcre.so
endif
DEPS_43 += $(BUILD)/bin/libmpr.so
DEPS_43 += $(BUILD)/inc/appweb.h
DEPS_43 += $(BUILD)/obj/appwebLib.o

ifeq ($(ME_COM_HTTP),1)
    LIBS_43 += -lhttp
endif
LIBS_43 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_43 += -lpcre
endif

$(BUILD)/bin/libappweb.so: $(DEPS_43)
	@echo '      [Link] $(BUILD)/bin/libappweb.so'
	$(CC) -shared -o $(BUILD)/bin/libappweb.so $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/appwebLib.o" $(LIBPATHS_43) $(LIBS_43) $(LIBS_43) $(LIBS) 
endif

ifeq ($(ME_COM_EST),1)
#
#   libest
#
DEPS_44 += $(BUILD)/inc/osdep.h
DEPS_44 += $(BUILD)/inc/est.h
DEPS_44 += $(BUILD)/obj/estLib.o

$(BUILD)/bin/libest.so: $(DEPS_44)
	@echo '      [Link] $(BUILD)/bin/libest.so'
	$(CC) -shared -o $(BUILD)/bin/libest.so $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/estLib.o" $(LIBS) 
endif

ifeq ($(ME_COM_SQLITE),1)
#
#   libsql
#
DEPS_45 += $(BUILD)/inc/sqlite3.h
DEPS_45 += $(BUILD)/obj/sqlite3.o

$(BUILD)/bin/libsql.so: $(DEPS_45)
	@echo '      [Link] $(BUILD)/bin/libsql.so'
	$(CC) -shared -o $(BUILD)/bin/libsql.so $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/sqlite3.o" $(LIBS) 
endif

#
#   libmod_esp
#
ifeq ($(ME_COM_APPWEB),1)
    DEPS_46 += $(BUILD)/bin/libappweb.so
endif
ifeq ($(ME_COM_SQLITE),1)
    DEPS_46 += $(BUILD)/bin/libsql.so
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

ifeq ($(ME_COM_APPWEB),1)
    LIBS_46 += -lappweb
endif
ifeq ($(ME_COM_HTTP),1)
    LIBS_46 += -lhttp
endif
LIBS_46 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_46 += -lpcre
endif
ifeq ($(ME_COM_SQLITE),1)
    LIBS_46 += -lsql
endif

$(BUILD)/bin/libmod_esp.so: $(DEPS_46)
	@echo '      [Link] $(BUILD)/bin/libmod_esp.so'
	$(CC) -shared -o $(BUILD)/bin/libmod_esp.so $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/edi.o" "$(BUILD)/obj/espAbbrev.o" "$(BUILD)/obj/espConfig.o" "$(BUILD)/obj/espFramework.o" "$(BUILD)/obj/espHandler.o" "$(BUILD)/obj/espHtml.o" "$(BUILD)/obj/espTemplate.o" "$(BUILD)/obj/mdb.o" "$(BUILD)/obj/sdb.o" $(LIBPATHS_46) $(LIBS_46) $(LIBS_46) $(LIBS) 

#
#   libmprssl
#
DEPS_47 += $(BUILD)/bin/libmpr.so
ifeq ($(ME_COM_EST),1)
    DEPS_47 += $(BUILD)/bin/libest.so
endif
DEPS_47 += $(BUILD)/obj/mprSsl.o

LIBS_47 += -lmpr
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_47 += -lssl
    LIBPATHS_47 += -L$(ME_COM_OPENSSL_PATH)
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_47 += -lcrypto
    LIBPATHS_47 += -L$(ME_COM_OPENSSL_PATH)
endif
ifeq ($(ME_COM_EST),1)
    LIBS_47 += -lest
endif

$(BUILD)/bin/libmprssl.so: $(DEPS_47)
	@echo '      [Link] $(BUILD)/bin/libmprssl.so'
	$(CC) -shared -o $(BUILD)/bin/libmprssl.so $(LDFLAGS) $(LIBPATHS)  "$(BUILD)/obj/mprSsl.o" $(LIBPATHS_47) $(LIBS_47) $(LIBS_47) $(LIBS) 

#
#   manager
#
DEPS_48 += $(BUILD)/bin/libmpr.so
DEPS_48 += $(BUILD)/obj/manager.o

LIBS_48 += -lmpr

$(BUILD)/bin/espman: $(DEPS_48)
	@echo '      [Link] $(BUILD)/bin/espman'
	$(CC) -o $(BUILD)/bin/espman $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/manager.o" $(LIBPATHS_48) $(LIBS_48) $(LIBS_48) $(LIBS) $(LIBS) 


#
#   installBinary
#

installBinary: $(DEPS_49)
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
	cp $(BUILD)/bin/libssl*.so* $(ME_VAPP_PREFIX)/bin/libssl*.so* ; \
	cp $(BUILD)/bin/libcrypto*.so* $(ME_VAPP_PREFIX)/bin/libcrypto*.so* ; \
	fi ; \
	mkdir -p "$(ME_VAPP_PREFIX)/bin" ; \
	cp $(BUILD)/bin/ca.crt $(ME_VAPP_PREFIX)/bin/ca.crt ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.2.0" ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.2.0/client" ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.2.0/client/assets" ; \
	cp ../../../dev/esp/src/paks/esp-html-mvc/client/assets/favicon.ico $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.2.0/client/assets/favicon.ico ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.2.0/client/css" ; \
	cp ../../../dev/esp/src/paks/esp-html-mvc/client/css/all.css $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.2.0/client/css/all.css ; \
	cp ../../../dev/esp/src/paks/esp-html-mvc/client/css/all.less $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.2.0/client/css/all.less ; \
	cp ../../../dev/esp/src/paks/esp-html-mvc/client/index.esp $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.2.0/client/index.esp ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.2.0/css" ; \
	cp ../../../dev/esp/src/paks/esp-html-mvc/css/app.less $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.2.0/css/app.less ; \
	cp ../../../dev/esp/src/paks/esp-html-mvc/css/theme.less $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.2.0/css/theme.less ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.2.0/generate" ; \
	cp ../../../dev/esp/src/paks/esp-html-mvc/generate/appweb.conf $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.2.0/generate/appweb.conf ; \
	cp ../../../dev/esp/src/paks/esp-html-mvc/generate/controller.c $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.2.0/generate/controller.c ; \
	cp ../../../dev/esp/src/paks/esp-html-mvc/generate/controllerSingleton.c $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.2.0/generate/controllerSingleton.c ; \
	cp ../../../dev/esp/src/paks/esp-html-mvc/generate/edit.esp $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.2.0/generate/edit.esp ; \
	cp ../../../dev/esp/src/paks/esp-html-mvc/generate/list.esp $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.2.0/generate/list.esp ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.2.0/layouts" ; \
	cp ../../../dev/esp/src/paks/esp-html-mvc/layouts/default.esp $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.2.0/layouts/default.esp ; \
	cp ../../../dev/esp/src/paks/esp-html-mvc/LICENSE.md $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.2.0/LICENSE.md ; \
	cp ../../../dev/esp/src/paks/esp-html-mvc/package.json $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.2.0/package.json ; \
	cp ../../../dev/esp/src/paks/esp-html-mvc/README.md $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.2.0/README.md ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-mvc/5.2.0" ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-mvc/5.2.0/generate" ; \
	cp ../../../dev/esp/src/paks/esp-mvc/generate/appweb.conf $(ME_VAPP_PREFIX)/esp/esp-mvc/5.2.0/generate/appweb.conf ; \
	cp ../../../dev/esp/src/paks/esp-mvc/generate/controller.c $(ME_VAPP_PREFIX)/esp/esp-mvc/5.2.0/generate/controller.c ; \
	cp ../../../dev/esp/src/paks/esp-mvc/generate/migration.c $(ME_VAPP_PREFIX)/esp/esp-mvc/5.2.0/generate/migration.c ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-mvc/5.2.0/generate/src" ; \
	cp ../../../dev/esp/src/paks/esp-mvc/generate/src/app.c $(ME_VAPP_PREFIX)/esp/esp-mvc/5.2.0/generate/src/app.c ; \
	cp ../../../dev/esp/src/paks/esp-mvc/LICENSE.md $(ME_VAPP_PREFIX)/esp/esp-mvc/5.2.0/LICENSE.md ; \
	cp ../../../dev/esp/src/paks/esp-mvc/package.json $(ME_VAPP_PREFIX)/esp/esp-mvc/5.2.0/package.json ; \
	cp ../../../dev/esp/src/paks/esp-mvc/README.md $(ME_VAPP_PREFIX)/esp/esp-mvc/5.2.0/README.md ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-server/5.2.0" ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-server/5.2.0/generate" ; \
	cp ../../../dev/esp/src/paks/esp-server/generate/appweb.conf $(ME_VAPP_PREFIX)/esp/esp-server/5.2.0/generate/appweb.conf ; \
	cp ../../../dev/esp/src/paks/esp-server/LICENSE.md $(ME_VAPP_PREFIX)/esp/esp-server/5.2.0/LICENSE.md ; \
	cp ../../../dev/esp/src/paks/esp-server/package.json $(ME_VAPP_PREFIX)/esp/esp-server/5.2.0/package.json ; \
	cp ../../../dev/esp/src/paks/esp-server/README.md $(ME_VAPP_PREFIX)/esp/esp-server/5.2.0/README.md ; \
	mkdir -p "$(ME_VAPP_PREFIX)/bin" ; \
	cp $(BUILD)/bin/esp.conf $(ME_VAPP_PREFIX)/bin/esp.conf ; \
	mkdir -p "$(ME_VAPP_PREFIX)/bin" ; \
	cp $(BUILD)/bin/libappweb.so $(ME_VAPP_PREFIX)/bin/libappweb.so ; \
	cp $(BUILD)/bin/libhttp.so $(ME_VAPP_PREFIX)/bin/libhttp.so ; \
	cp $(BUILD)/bin/libmpr.so $(ME_VAPP_PREFIX)/bin/libmpr.so ; \
	cp $(BUILD)/bin/libmprssl.so $(ME_VAPP_PREFIX)/bin/libmprssl.so ; \
	cp $(BUILD)/bin/libpcre.so $(ME_VAPP_PREFIX)/bin/libpcre.so ; \
	cp $(BUILD)/bin/libsql.so $(ME_VAPP_PREFIX)/bin/libsql.so ; \
	cp $(BUILD)/bin/libmod_esp.so $(ME_VAPP_PREFIX)/bin/libmod_esp.so ; \
	if [ "$(ME_COM_EST)" = 1 ]; then true ; \
	mkdir -p "$(ME_VAPP_PREFIX)/bin" ; \
	cp $(BUILD)/bin/libest.so $(ME_VAPP_PREFIX)/bin/libest.so ; \
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
DEPS_50 += stop
DEPS_50 += installBinary
DEPS_50 += start

install: $(DEPS_50)

#
#   uninstall
#
DEPS_51 += stop

uninstall: $(DEPS_51)
	( \
	cd ../../.paks/me-package/0.8.4; \
	rm -fr "$(ME_VAPP_PREFIX)" ; \
	rm -f "$(ME_APP_PREFIX)/latest" ; \
	rmdir -p "$(ME_APP_PREFIX)" 2>/dev/null ; true ; \
	)

#
#   version
#

version: $(DEPS_52)
	echo 5.2.0

