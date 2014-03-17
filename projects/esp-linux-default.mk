#
#   esp-linux-default.mk -- Makefile to build Embedthis ESP for linux
#

NAME                  := esp
VERSION               := 0.9.0
PROFILE               ?= default
ARCH                  ?= $(shell uname -m | sed 's/i.86/x86/;s/x86_64/x64/;s/arm.*/arm/;s/mips.*/mips/')
CC_ARCH               ?= $(shell echo $(ARCH) | sed 's/x86/i686/;s/x64/x86_64/')
OS                    ?= linux
CC                    ?= gcc
LD                    ?= ld
CONFIG                ?= $(OS)-$(ARCH)-$(PROFILE)
LBIN                  ?= $(CONFIG)/bin
PATH                  := $(LBIN):$(PATH)

ME_EXT_APPWEB         ?= 1
ME_EXT_CGI            ?= 0
ME_EXT_DIR            ?= 0
ME_EXT_EST            ?= 1
ME_EXT_MATRIXSSL      ?= 0
ME_EXT_OPENSSL        ?= 0
ME_EXT_PCRE           ?= 1
ME_EXT_SSL            ?= 1

ME_EXT_APPWEB_PATH    ?= src/paks/appweb
ME_EXT_COMPILER_PATH  ?= gcc
ME_EXT_DOXYGEN_PATH   ?= doxygen
ME_EXT_DSI_PATH       ?= dsi
ME_EXT_EST_PATH       ?= src/paks/est
ME_EXT_GZIP_PATH      ?= gzip
ME_EXT_HTMLMIN_PATH   ?= htmlmin
ME_EXT_HTTP_PATH      ?= src/paks/http/http.me
ME_EXT_LIB_PATH       ?= ar
ME_EXT_LINK_PATH      ?= ld
ME_EXT_MAN_PATH       ?= man
ME_EXT_MAN2HTML_PATH  ?= man2html
ME_EXT_MATRIXSSL_PATH ?= /usr/src/matrixssl
ME_EXT_MPR_PATH       ?= src/paks/mpr/mpr.me
ME_EXT_NANOSSL_PATH   ?= /usr/src/nanossl
ME_EXT_OPENSSL_PATH   ?= /usr/src/openssl
ME_EXT_OSDEP_PATH     ?= src/paks/osdep/osdep.me
ME_EXT_PAK_PATH       ?= pak
ME_EXT_PCRE_PATH      ?= src/paks/pcre/pcre.me
ME_EXT_RECESS_PATH    ?= recess
ME_EXT_UGLIFYJS_PATH  ?= uglifyjs
ME_EXT_UTEST_PATH     ?= utest
ME_EXT_VXWORKS_PATH   ?= $(WIND_BASE)
ME_EXT_ZIP_PATH       ?= zip

export WIND_HOME      ?= $(WIND_BASE)/..

CFLAGS                += -fPIC -w
DFLAGS                += -D_REENTRANT -DPIC $(patsubst %,-D%,$(filter ME_%,$(MAKEFLAGS))) -DME_EXT_APPWEB=$(ME_EXT_APPWEB) -DME_EXT_CGI=$(ME_EXT_CGI) -DME_EXT_DIR=$(ME_EXT_DIR) -DME_EXT_EST=$(ME_EXT_EST) -DME_EXT_MATRIXSSL=$(ME_EXT_MATRIXSSL) -DME_EXT_OPENSSL=$(ME_EXT_OPENSSL) -DME_EXT_PCRE=$(ME_EXT_PCRE) -DME_EXT_SSL=$(ME_EXT_SSL) 
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


ifeq ($(ME_EXT_APPWEB),1)
    TARGETS           += $(CONFIG)/bin/libappweb.so
endif
ifeq ($(ME_EXT_EST),1)
    TARGETS           += $(CONFIG)/bin/libest.so
endif
TARGETS               += $(CONFIG)/bin/ca.crt
TARGETS               += $(CONFIG)/bin/http
TARGETS               += $(CONFIG)/bin/libmprssl.so
TARGETS               += $(CONFIG)/bin/libmod_esp.so
TARGETS               += $(CONFIG)/bin/esp
TARGETS               += $(CONFIG)/bin/esp.conf
TARGETS               += $(CONFIG)/paks

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
	rm -f "$(CONFIG)/bin/libappweb.so"
	rm -f "$(CONFIG)/bin/libest.so"
	rm -f "$(CONFIG)/bin/ca.crt"
	rm -f "$(CONFIG)/bin/libhttp.so"
	rm -f "$(CONFIG)/bin/http"
	rm -f "$(CONFIG)/bin/libmpr.so"
	rm -f "$(CONFIG)/bin/libmprssl.so"
	rm -f "$(CONFIG)/bin/makerom"
	rm -f "$(CONFIG)/bin/libpcre.so"
	rm -f "$(CONFIG)/bin/libmod_esp.so"
	rm -f "$(CONFIG)/bin/esp"
	rm -f "$(CONFIG)/bin/esp.conf"
	rm -f "$(CONFIG)/obj/appwebLib.o"
	rm -f "$(CONFIG)/obj/estLib.o"
	rm -f "$(CONFIG)/obj/httpLib.o"
	rm -f "$(CONFIG)/obj/http.o"
	rm -f "$(CONFIG)/obj/mprLib.o"
	rm -f "$(CONFIG)/obj/mprSsl.o"
	rm -f "$(CONFIG)/obj/makerom.o"
	rm -f "$(CONFIG)/obj/pcre.o"
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
#   me.h
#
$(CONFIG)/inc/me.h: $(DEPS_3)
	@echo '      [Copy] $(CONFIG)/inc/me.h'

#
#   osdep.h
#
$(CONFIG)/inc/osdep.h: $(DEPS_4)
	@echo '      [Copy] $(CONFIG)/inc/osdep.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/paks/osdep/osdep.h $(CONFIG)/inc/osdep.h

#
#   mprLib.o
#
DEPS_5 += $(CONFIG)/inc/me.h
DEPS_5 += $(CONFIG)/inc/mpr.h
DEPS_5 += $(CONFIG)/inc/osdep.h

$(CONFIG)/obj/mprLib.o: \
    src/paks/mpr/mprLib.c $(DEPS_5)
	@echo '   [Compile] $(CONFIG)/obj/mprLib.o'
	$(CC) -c -o $(CONFIG)/obj/mprLib.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/paks/mpr/mprLib.c

#
#   libmpr
#
DEPS_6 += $(CONFIG)/inc/mpr.h
DEPS_6 += $(CONFIG)/inc/me.h
DEPS_6 += $(CONFIG)/inc/osdep.h
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
DEPS_8 += $(CONFIG)/inc/me.h
DEPS_8 += $(CONFIG)/inc/pcre.h

$(CONFIG)/obj/pcre.o: \
    src/paks/pcre/pcre.c $(DEPS_8)
	@echo '   [Compile] $(CONFIG)/obj/pcre.o'
	$(CC) -c -o $(CONFIG)/obj/pcre.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/paks/pcre/pcre.c

ifeq ($(ME_EXT_PCRE),1)
#
#   libpcre
#
DEPS_9 += $(CONFIG)/inc/pcre.h
DEPS_9 += $(CONFIG)/inc/me.h
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
DEPS_11 += $(CONFIG)/inc/me.h
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
DEPS_12 += $(CONFIG)/inc/me.h
DEPS_12 += $(CONFIG)/inc/osdep.h
DEPS_12 += $(CONFIG)/obj/mprLib.o
DEPS_12 += $(CONFIG)/bin/libmpr.so
DEPS_12 += $(CONFIG)/inc/pcre.h
DEPS_12 += $(CONFIG)/obj/pcre.o
ifeq ($(ME_EXT_PCRE),1)
    DEPS_12 += $(CONFIG)/bin/libpcre.so
endif
DEPS_12 += $(CONFIG)/inc/http.h
DEPS_12 += $(CONFIG)/obj/httpLib.o

LIBS_12 += -lmpr
ifeq ($(ME_EXT_PCRE),1)
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
DEPS_14 += $(CONFIG)/inc/me.h
DEPS_14 += $(CONFIG)/inc/appweb.h
DEPS_14 += $(CONFIG)/inc/pcre.h
DEPS_14 += $(CONFIG)/inc/mpr.h
DEPS_14 += $(CONFIG)/inc/http.h

$(CONFIG)/obj/appwebLib.o: \
    src/paks/appweb/appwebLib.c $(DEPS_14)
	@echo '   [Compile] $(CONFIG)/obj/appwebLib.o'
	$(CC) -c -o $(CONFIG)/obj/appwebLib.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/paks/appweb/appwebLib.c

ifeq ($(ME_EXT_APPWEB),1)
#
#   libappweb
#
DEPS_15 += $(CONFIG)/inc/mpr.h
DEPS_15 += $(CONFIG)/inc/me.h
DEPS_15 += $(CONFIG)/inc/osdep.h
DEPS_15 += $(CONFIG)/obj/mprLib.o
DEPS_15 += $(CONFIG)/bin/libmpr.so
DEPS_15 += $(CONFIG)/inc/pcre.h
DEPS_15 += $(CONFIG)/obj/pcre.o
ifeq ($(ME_EXT_PCRE),1)
    DEPS_15 += $(CONFIG)/bin/libpcre.so
endif
DEPS_15 += $(CONFIG)/inc/http.h
DEPS_15 += $(CONFIG)/obj/httpLib.o
DEPS_15 += $(CONFIG)/bin/libhttp.so
DEPS_15 += $(CONFIG)/inc/appweb.h
DEPS_15 += $(CONFIG)/obj/appwebLib.o

LIBS_15 += -lhttp
LIBS_15 += -lmpr
ifeq ($(ME_EXT_PCRE),1)
    LIBS_15 += -lpcre
endif

$(CONFIG)/bin/libappweb.so: $(DEPS_15)
	@echo '      [Link] $(CONFIG)/bin/libappweb.so'
	$(CC) -shared -o $(CONFIG)/bin/libappweb.so $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/appwebLib.o" $(LIBPATHS_15) $(LIBS_15) $(LIBS_15) $(LIBS) 
endif

#
#   est.h
#
$(CONFIG)/inc/est.h: $(DEPS_16)
	@echo '      [Copy] $(CONFIG)/inc/est.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/paks/est/est.h $(CONFIG)/inc/est.h

#
#   estLib.o
#
DEPS_17 += $(CONFIG)/inc/me.h
DEPS_17 += $(CONFIG)/inc/est.h
DEPS_17 += $(CONFIG)/inc/osdep.h

$(CONFIG)/obj/estLib.o: \
    src/paks/est/estLib.c $(DEPS_17)
	@echo '   [Compile] $(CONFIG)/obj/estLib.o'
	$(CC) -c -o $(CONFIG)/obj/estLib.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/paks/est/estLib.c

ifeq ($(ME_EXT_EST),1)
#
#   libest
#
DEPS_18 += $(CONFIG)/inc/est.h
DEPS_18 += $(CONFIG)/inc/me.h
DEPS_18 += $(CONFIG)/inc/osdep.h
DEPS_18 += $(CONFIG)/obj/estLib.o

$(CONFIG)/bin/libest.so: $(DEPS_18)
	@echo '      [Link] $(CONFIG)/bin/libest.so'
	$(CC) -shared -o $(CONFIG)/bin/libest.so $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/estLib.o" $(LIBS) 
endif

#
#   ca-crt
#
DEPS_19 += src/paks/est/ca.crt

$(CONFIG)/bin/ca.crt: $(DEPS_19)
	@echo '      [Copy] $(CONFIG)/bin/ca.crt'
	mkdir -p "$(CONFIG)/bin"
	cp src/paks/est/ca.crt $(CONFIG)/bin/ca.crt

#
#   http.o
#
DEPS_20 += $(CONFIG)/inc/me.h
DEPS_20 += $(CONFIG)/inc/http.h

$(CONFIG)/obj/http.o: \
    src/paks/http/http.c $(DEPS_20)
	@echo '   [Compile] $(CONFIG)/obj/http.o'
	$(CC) -c -o $(CONFIG)/obj/http.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/paks/http/http.c

#
#   httpcmd
#
DEPS_21 += $(CONFIG)/inc/mpr.h
DEPS_21 += $(CONFIG)/inc/me.h
DEPS_21 += $(CONFIG)/inc/osdep.h
DEPS_21 += $(CONFIG)/obj/mprLib.o
DEPS_21 += $(CONFIG)/bin/libmpr.so
DEPS_21 += $(CONFIG)/inc/pcre.h
DEPS_21 += $(CONFIG)/obj/pcre.o
ifeq ($(ME_EXT_PCRE),1)
    DEPS_21 += $(CONFIG)/bin/libpcre.so
endif
DEPS_21 += $(CONFIG)/inc/http.h
DEPS_21 += $(CONFIG)/obj/httpLib.o
DEPS_21 += $(CONFIG)/bin/libhttp.so
DEPS_21 += $(CONFIG)/obj/http.o

LIBS_21 += -lhttp
LIBS_21 += -lmpr
ifeq ($(ME_EXT_PCRE),1)
    LIBS_21 += -lpcre
endif

$(CONFIG)/bin/http: $(DEPS_21)
	@echo '      [Link] $(CONFIG)/bin/http'
	$(CC) -o $(CONFIG)/bin/http $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/http.o" $(LIBPATHS_21) $(LIBS_21) $(LIBS_21) $(LIBS) $(LIBS) 

#
#   mprSsl.o
#
DEPS_22 += $(CONFIG)/inc/me.h
DEPS_22 += $(CONFIG)/inc/mpr.h
DEPS_22 += $(CONFIG)/inc/est.h

$(CONFIG)/obj/mprSsl.o: \
    src/paks/mpr/mprSsl.c $(DEPS_22)
	@echo '   [Compile] $(CONFIG)/obj/mprSsl.o'
	$(CC) -c -o $(CONFIG)/obj/mprSsl.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/paks/mpr/mprSsl.c

#
#   libmprssl
#
DEPS_23 += $(CONFIG)/inc/mpr.h
DEPS_23 += $(CONFIG)/inc/me.h
DEPS_23 += $(CONFIG)/inc/osdep.h
DEPS_23 += $(CONFIG)/obj/mprLib.o
DEPS_23 += $(CONFIG)/bin/libmpr.so
DEPS_23 += $(CONFIG)/inc/est.h
DEPS_23 += $(CONFIG)/obj/estLib.o
ifeq ($(ME_EXT_EST),1)
    DEPS_23 += $(CONFIG)/bin/libest.so
endif
DEPS_23 += $(CONFIG)/obj/mprSsl.o

LIBS_23 += -lmpr
ifeq ($(ME_EXT_EST),1)
    LIBS_23 += -lest
endif

$(CONFIG)/bin/libmprssl.so: $(DEPS_23)
	@echo '      [Link] $(CONFIG)/bin/libmprssl.so'
	$(CC) -shared -o $(CONFIG)/bin/libmprssl.so $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/mprSsl.o" $(LIBPATHS_23) $(LIBS_23) $(LIBS_23) $(LIBS) 

#
#   edi.h
#
$(CONFIG)/inc/edi.h: $(DEPS_24)
	@echo '      [Copy] $(CONFIG)/inc/edi.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/edi.h $(CONFIG)/inc/edi.h

#
#   esp.h
#
$(CONFIG)/inc/esp.h: $(DEPS_25)
	@echo '      [Copy] $(CONFIG)/inc/esp.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/esp.h $(CONFIG)/inc/esp.h

#
#   mdb.h
#
$(CONFIG)/inc/mdb.h: $(DEPS_26)
	@echo '      [Copy] $(CONFIG)/inc/mdb.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/mdb.h $(CONFIG)/inc/mdb.h

#
#   edi.o
#
DEPS_27 += $(CONFIG)/inc/me.h
DEPS_27 += $(CONFIG)/inc/edi.h
DEPS_27 += $(CONFIG)/inc/pcre.h

$(CONFIG)/obj/edi.o: \
    src/edi.c $(DEPS_27)
	@echo '   [Compile] $(CONFIG)/obj/edi.o'
	$(CC) -c -o $(CONFIG)/obj/edi.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/edi.c

#
#   espAbbrev.o
#
DEPS_28 += $(CONFIG)/inc/me.h
DEPS_28 += $(CONFIG)/inc/esp.h

$(CONFIG)/obj/espAbbrev.o: \
    src/espAbbrev.c $(DEPS_28)
	@echo '   [Compile] $(CONFIG)/obj/espAbbrev.o'
	$(CC) -c -o $(CONFIG)/obj/espAbbrev.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/espAbbrev.c

#
#   espDeprecated.o
#
DEPS_29 += $(CONFIG)/inc/me.h
DEPS_29 += $(CONFIG)/inc/esp.h
DEPS_29 += $(CONFIG)/inc/edi.h

$(CONFIG)/obj/espDeprecated.o: \
    src/espDeprecated.c $(DEPS_29)
	@echo '   [Compile] $(CONFIG)/obj/espDeprecated.o'
	$(CC) -c -o $(CONFIG)/obj/espDeprecated.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/espDeprecated.c

#
#   espFramework.o
#
DEPS_30 += $(CONFIG)/inc/me.h
DEPS_30 += $(CONFIG)/inc/esp.h

$(CONFIG)/obj/espFramework.o: \
    src/espFramework.c $(DEPS_30)
	@echo '   [Compile] $(CONFIG)/obj/espFramework.o'
	$(CC) -c -o $(CONFIG)/obj/espFramework.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/espFramework.c

#
#   espHandler.o
#
DEPS_31 += $(CONFIG)/inc/me.h
DEPS_31 += $(CONFIG)/inc/http.h
DEPS_31 += $(CONFIG)/inc/esp.h
DEPS_31 += $(CONFIG)/inc/edi.h

$(CONFIG)/obj/espHandler.o: \
    src/espHandler.c $(DEPS_31)
	@echo '   [Compile] $(CONFIG)/obj/espHandler.o'
	$(CC) -c -o $(CONFIG)/obj/espHandler.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/espHandler.c

#
#   espHtml.o
#
DEPS_32 += $(CONFIG)/inc/me.h
DEPS_32 += $(CONFIG)/inc/esp.h
DEPS_32 += $(CONFIG)/inc/edi.h

$(CONFIG)/obj/espHtml.o: \
    src/espHtml.c $(DEPS_32)
	@echo '   [Compile] $(CONFIG)/obj/espHtml.o'
	$(CC) -c -o $(CONFIG)/obj/espHtml.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/espHtml.c

#
#   espTemplate.o
#
DEPS_33 += $(CONFIG)/inc/me.h
DEPS_33 += $(CONFIG)/inc/esp.h

$(CONFIG)/obj/espTemplate.o: \
    src/espTemplate.c $(DEPS_33)
	@echo '   [Compile] $(CONFIG)/obj/espTemplate.o'
	$(CC) -c -o $(CONFIG)/obj/espTemplate.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/espTemplate.c

#
#   mdb.o
#
DEPS_34 += $(CONFIG)/inc/me.h
DEPS_34 += $(CONFIG)/inc/http.h
DEPS_34 += $(CONFIG)/inc/edi.h
DEPS_34 += $(CONFIG)/inc/mdb.h
DEPS_34 += $(CONFIG)/inc/pcre.h

$(CONFIG)/obj/mdb.o: \
    src/mdb.c $(DEPS_34)
	@echo '   [Compile] $(CONFIG)/obj/mdb.o'
	$(CC) -c -o $(CONFIG)/obj/mdb.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/mdb.c

#
#   sdb.o
#
DEPS_35 += $(CONFIG)/inc/me.h
DEPS_35 += $(CONFIG)/inc/http.h
DEPS_35 += $(CONFIG)/inc/edi.h

$(CONFIG)/obj/sdb.o: \
    src/sdb.c $(DEPS_35)
	@echo '   [Compile] $(CONFIG)/obj/sdb.o'
	$(CC) -c -o $(CONFIG)/obj/sdb.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/sdb.c

#
#   libmod_esp
#
DEPS_36 += $(CONFIG)/inc/mpr.h
DEPS_36 += $(CONFIG)/inc/me.h
DEPS_36 += $(CONFIG)/inc/osdep.h
DEPS_36 += $(CONFIG)/obj/mprLib.o
DEPS_36 += $(CONFIG)/bin/libmpr.so
DEPS_36 += $(CONFIG)/inc/pcre.h
DEPS_36 += $(CONFIG)/obj/pcre.o
ifeq ($(ME_EXT_PCRE),1)
    DEPS_36 += $(CONFIG)/bin/libpcre.so
endif
DEPS_36 += $(CONFIG)/inc/http.h
DEPS_36 += $(CONFIG)/obj/httpLib.o
DEPS_36 += $(CONFIG)/bin/libhttp.so
DEPS_36 += $(CONFIG)/inc/appweb.h
DEPS_36 += $(CONFIG)/obj/appwebLib.o
ifeq ($(ME_EXT_APPWEB),1)
    DEPS_36 += $(CONFIG)/bin/libappweb.so
endif
DEPS_36 += $(CONFIG)/inc/edi.h
DEPS_36 += $(CONFIG)/inc/esp.h
DEPS_36 += $(CONFIG)/inc/mdb.h
DEPS_36 += $(CONFIG)/obj/edi.o
DEPS_36 += $(CONFIG)/obj/espAbbrev.o
DEPS_36 += $(CONFIG)/obj/espDeprecated.o
DEPS_36 += $(CONFIG)/obj/espFramework.o
DEPS_36 += $(CONFIG)/obj/espHandler.o
DEPS_36 += $(CONFIG)/obj/espHtml.o
DEPS_36 += $(CONFIG)/obj/espTemplate.o
DEPS_36 += $(CONFIG)/obj/mdb.o
DEPS_36 += $(CONFIG)/obj/sdb.o

ifeq ($(ME_EXT_APPWEB),1)
    LIBS_36 += -lappweb
endif
LIBS_36 += -lhttp
LIBS_36 += -lmpr
ifeq ($(ME_EXT_PCRE),1)
    LIBS_36 += -lpcre
endif

$(CONFIG)/bin/libmod_esp.so: $(DEPS_36)
	@echo '      [Link] $(CONFIG)/bin/libmod_esp.so'
	$(CC) -shared -o $(CONFIG)/bin/libmod_esp.so $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/edi.o" "$(CONFIG)/obj/espAbbrev.o" "$(CONFIG)/obj/espDeprecated.o" "$(CONFIG)/obj/espFramework.o" "$(CONFIG)/obj/espHandler.o" "$(CONFIG)/obj/espHtml.o" "$(CONFIG)/obj/espTemplate.o" "$(CONFIG)/obj/mdb.o" "$(CONFIG)/obj/sdb.o" $(LIBPATHS_36) $(LIBS_36) $(LIBS_36) $(LIBS) 

#
#   esp.o
#
DEPS_37 += $(CONFIG)/inc/me.h
DEPS_37 += $(CONFIG)/inc/esp.h

$(CONFIG)/obj/esp.o: \
    src/esp.c $(DEPS_37)
	@echo '   [Compile] $(CONFIG)/obj/esp.o'
	$(CC) -c -o $(CONFIG)/obj/esp.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/esp.c

#
#   espcmd
#
DEPS_38 += $(CONFIG)/inc/mpr.h
DEPS_38 += $(CONFIG)/inc/me.h
DEPS_38 += $(CONFIG)/inc/osdep.h
DEPS_38 += $(CONFIG)/obj/mprLib.o
DEPS_38 += $(CONFIG)/bin/libmpr.so
DEPS_38 += $(CONFIG)/inc/pcre.h
DEPS_38 += $(CONFIG)/obj/pcre.o
ifeq ($(ME_EXT_PCRE),1)
    DEPS_38 += $(CONFIG)/bin/libpcre.so
endif
DEPS_38 += $(CONFIG)/inc/http.h
DEPS_38 += $(CONFIG)/obj/httpLib.o
DEPS_38 += $(CONFIG)/bin/libhttp.so
DEPS_38 += $(CONFIG)/inc/appweb.h
DEPS_38 += $(CONFIG)/obj/appwebLib.o
ifeq ($(ME_EXT_APPWEB),1)
    DEPS_38 += $(CONFIG)/bin/libappweb.so
endif
DEPS_38 += $(CONFIG)/inc/edi.h
DEPS_38 += $(CONFIG)/inc/esp.h
DEPS_38 += $(CONFIG)/inc/mdb.h
DEPS_38 += $(CONFIG)/obj/edi.o
DEPS_38 += $(CONFIG)/obj/espAbbrev.o
DEPS_38 += $(CONFIG)/obj/espDeprecated.o
DEPS_38 += $(CONFIG)/obj/espFramework.o
DEPS_38 += $(CONFIG)/obj/espHandler.o
DEPS_38 += $(CONFIG)/obj/espHtml.o
DEPS_38 += $(CONFIG)/obj/espTemplate.o
DEPS_38 += $(CONFIG)/obj/mdb.o
DEPS_38 += $(CONFIG)/obj/sdb.o
DEPS_38 += $(CONFIG)/bin/libmod_esp.so
DEPS_38 += $(CONFIG)/obj/esp.o

ifeq ($(ME_EXT_APPWEB),1)
    LIBS_38 += -lappweb
endif
LIBS_38 += -lhttp
LIBS_38 += -lmpr
ifeq ($(ME_EXT_PCRE),1)
    LIBS_38 += -lpcre
endif
LIBS_38 += -lmod_esp

$(CONFIG)/bin/esp: $(DEPS_38)
	@echo '      [Link] $(CONFIG)/bin/esp'
	$(CC) -o $(CONFIG)/bin/esp $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/edi.o" "$(CONFIG)/obj/esp.o" "$(CONFIG)/obj/espAbbrev.o" "$(CONFIG)/obj/espDeprecated.o" "$(CONFIG)/obj/espFramework.o" "$(CONFIG)/obj/espHandler.o" "$(CONFIG)/obj/espHtml.o" "$(CONFIG)/obj/espTemplate.o" "$(CONFIG)/obj/mdb.o" "$(CONFIG)/obj/sdb.o" $(LIBPATHS_38) $(LIBS_38) $(LIBS_38) $(LIBS) $(LIBS) 

#
#   esp.conf
#
DEPS_39 += src/esp.conf

$(CONFIG)/bin/esp.conf: $(DEPS_39)
	@echo '      [Copy] $(CONFIG)/bin/esp.conf'
	mkdir -p "$(CONFIG)/bin"
	cp src/esp.conf $(CONFIG)/bin/esp.conf

#
#   esp-paks
#
DEPS_40 += src/paks/angular
DEPS_40 += src/paks/angular/angular-animate.js
DEPS_40 += src/paks/angular/angular-csp.css
DEPS_40 += src/paks/angular/angular-route.js
DEPS_40 += src/paks/angular/angular.js
DEPS_40 += src/paks/angular/package.json
DEPS_40 += src/paks/appweb
DEPS_40 += src/paks/appweb/appweb.h
DEPS_40 += src/paks/appweb/appweb.me
DEPS_40 += src/paks/appweb/appwebLib.c
DEPS_40 += src/paks/appweb/LICENSE.md
DEPS_40 += src/paks/appweb/package.json
DEPS_40 += src/paks/appweb/README.md
DEPS_40 += src/paks/esp-angular
DEPS_40 += src/paks/esp-angular/esp-click.js
DEPS_40 += src/paks/esp-angular/esp-edit.js
DEPS_40 += src/paks/esp-angular/esp-field-errors.js
DEPS_40 += src/paks/esp-angular/esp-fixnum.js
DEPS_40 += src/paks/esp-angular/esp-format.js
DEPS_40 += src/paks/esp-angular/esp-input-group.js
DEPS_40 += src/paks/esp-angular/esp-input.js
DEPS_40 += src/paks/esp-angular/esp-resource.js
DEPS_40 += src/paks/esp-angular/esp-session.js
DEPS_40 += src/paks/esp-angular/esp-titlecase.js
DEPS_40 += src/paks/esp-angular/esp.js
DEPS_40 += src/paks/esp-angular/package.json
DEPS_40 += src/paks/esp-angular-mvc
DEPS_40 += src/paks/esp-angular-mvc/package.json
DEPS_40 += src/paks/esp-angular-mvc/templates
DEPS_40 += src/paks/esp-angular-mvc/templates/esp-angular-mvc
DEPS_40 += src/paks/esp-angular-mvc/templates/esp-angular-mvc/appweb.conf
DEPS_40 += src/paks/esp-angular-mvc/templates/esp-angular-mvc/client
DEPS_40 += src/paks/esp-angular-mvc/templates/esp-angular-mvc/client/app
DEPS_40 += src/paks/esp-angular-mvc/templates/esp-angular-mvc/client/app/main.js
DEPS_40 += src/paks/esp-angular-mvc/templates/esp-angular-mvc/client/assets
DEPS_40 += src/paks/esp-angular-mvc/templates/esp-angular-mvc/client/assets/favicon.ico
DEPS_40 += src/paks/esp-angular-mvc/templates/esp-angular-mvc/client/css
DEPS_40 += src/paks/esp-angular-mvc/templates/esp-angular-mvc/client/css/all.css
DEPS_40 += src/paks/esp-angular-mvc/templates/esp-angular-mvc/client/css/all.less
DEPS_40 += src/paks/esp-angular-mvc/templates/esp-angular-mvc/client/css/app.less
DEPS_40 += src/paks/esp-angular-mvc/templates/esp-angular-mvc/client/css/fix.css
DEPS_40 += src/paks/esp-angular-mvc/templates/esp-angular-mvc/client/css/theme.less
DEPS_40 += src/paks/esp-angular-mvc/templates/esp-angular-mvc/client/index.esp
DEPS_40 += src/paks/esp-angular-mvc/templates/esp-angular-mvc/client/pages
DEPS_40 += src/paks/esp-angular-mvc/templates/esp-angular-mvc/client/pages/splash.html
DEPS_40 += src/paks/esp-angular-mvc/templates/esp-angular-mvc/controller-singleton.c
DEPS_40 += src/paks/esp-angular-mvc/templates/esp-angular-mvc/controller.c
DEPS_40 += src/paks/esp-angular-mvc/templates/esp-angular-mvc/controller.js
DEPS_40 += src/paks/esp-angular-mvc/templates/esp-angular-mvc/edit.html
DEPS_40 += src/paks/esp-angular-mvc/templates/esp-angular-mvc/list.html
DEPS_40 += src/paks/esp-angular-mvc/templates/esp-angular-mvc/model.js
DEPS_40 += src/paks/esp-angular-mvc/templates/esp-angular-mvc/start.me
DEPS_40 += src/paks/esp-html-mvc
DEPS_40 += src/paks/esp-html-mvc/package.json
DEPS_40 += src/paks/esp-html-mvc/templates
DEPS_40 += src/paks/esp-html-mvc/templates/esp-html-mvc
DEPS_40 += src/paks/esp-html-mvc/templates/esp-html-mvc/appweb.conf
DEPS_40 += src/paks/esp-html-mvc/templates/esp-html-mvc/client
DEPS_40 += src/paks/esp-html-mvc/templates/esp-html-mvc/client/assets
DEPS_40 += src/paks/esp-html-mvc/templates/esp-html-mvc/client/assets/favicon.ico
DEPS_40 += src/paks/esp-html-mvc/templates/esp-html-mvc/client/css
DEPS_40 += src/paks/esp-html-mvc/templates/esp-html-mvc/client/css/all.css
DEPS_40 += src/paks/esp-html-mvc/templates/esp-html-mvc/client/css/all.less
DEPS_40 += src/paks/esp-html-mvc/templates/esp-html-mvc/client/css/app.less
DEPS_40 += src/paks/esp-html-mvc/templates/esp-html-mvc/client/css/theme.less
DEPS_40 += src/paks/esp-html-mvc/templates/esp-html-mvc/client/index.esp
DEPS_40 += src/paks/esp-html-mvc/templates/esp-html-mvc/client/layouts
DEPS_40 += src/paks/esp-html-mvc/templates/esp-html-mvc/client/layouts/default.esp
DEPS_40 += src/paks/esp-html-mvc/templates/esp-html-mvc/controller-singleton.c
DEPS_40 += src/paks/esp-html-mvc/templates/esp-html-mvc/controller.c
DEPS_40 += src/paks/esp-html-mvc/templates/esp-html-mvc/edit.esp
DEPS_40 += src/paks/esp-html-mvc/templates/esp-html-mvc/list.esp
DEPS_40 += src/paks/esp-html-mvc/templates/esp-html-mvc/start.me
DEPS_40 += src/paks/esp-legacy-mvc
DEPS_40 += src/paks/esp-legacy-mvc/package.json
DEPS_40 += src/paks/esp-legacy-mvc/templates
DEPS_40 += src/paks/esp-legacy-mvc/templates/esp-legacy-mvc
DEPS_40 += src/paks/esp-legacy-mvc/templates/esp-legacy-mvc/appweb.conf
DEPS_40 += src/paks/esp-legacy-mvc/templates/esp-legacy-mvc/controller.c
DEPS_40 += src/paks/esp-legacy-mvc/templates/esp-legacy-mvc/edit.esp
DEPS_40 += src/paks/esp-legacy-mvc/templates/esp-legacy-mvc/layouts
DEPS_40 += src/paks/esp-legacy-mvc/templates/esp-legacy-mvc/layouts/default.esp
DEPS_40 += src/paks/esp-legacy-mvc/templates/esp-legacy-mvc/list.esp
DEPS_40 += src/paks/esp-legacy-mvc/templates/esp-legacy-mvc/migration.c
DEPS_40 += src/paks/esp-legacy-mvc/templates/esp-legacy-mvc/src
DEPS_40 += src/paks/esp-legacy-mvc/templates/esp-legacy-mvc/src/app.c
DEPS_40 += src/paks/esp-legacy-mvc/templates/esp-legacy-mvc/static
DEPS_40 += src/paks/esp-legacy-mvc/templates/esp-legacy-mvc/static/css
DEPS_40 += src/paks/esp-legacy-mvc/templates/esp-legacy-mvc/static/css/all.css
DEPS_40 += src/paks/esp-legacy-mvc/templates/esp-legacy-mvc/static/images
DEPS_40 += src/paks/esp-legacy-mvc/templates/esp-legacy-mvc/static/images/banner.jpg
DEPS_40 += src/paks/esp-legacy-mvc/templates/esp-legacy-mvc/static/images/favicon.ico
DEPS_40 += src/paks/esp-legacy-mvc/templates/esp-legacy-mvc/static/images/splash.jpg
DEPS_40 += src/paks/esp-legacy-mvc/templates/esp-legacy-mvc/static/index.esp
DEPS_40 += src/paks/esp-legacy-mvc/templates/esp-legacy-mvc/static/js
DEPS_40 += src/paks/esp-legacy-mvc/templates/esp-legacy-mvc/static/js/jquery.esp.js
DEPS_40 += src/paks/esp-legacy-mvc/templates/esp-legacy-mvc/static/js/jquery.js
DEPS_40 += src/paks/esp-server
DEPS_40 += src/paks/esp-server/package.json
DEPS_40 += src/paks/esp-server/templates
DEPS_40 += src/paks/esp-server/templates/esp-server
DEPS_40 += src/paks/esp-server/templates/esp-server/appweb.conf
DEPS_40 += src/paks/esp-server/templates/esp-server/controller.c
DEPS_40 += src/paks/esp-server/templates/esp-server/migration.c
DEPS_40 += src/paks/esp-server/templates/esp-server/src
DEPS_40 += src/paks/esp-server/templates/esp-server/src/app.c
DEPS_40 += src/paks/est
DEPS_40 += src/paks/est/ca.crt
DEPS_40 += src/paks/est/est.h
DEPS_40 += src/paks/est/est.me
DEPS_40 += src/paks/est/estLib.c
DEPS_40 += src/paks/est/LICENSE.md
DEPS_40 += src/paks/est/package.json
DEPS_40 += src/paks/est/README.md
DEPS_40 += src/paks/http
DEPS_40 += src/paks/http/http.c
DEPS_40 += src/paks/http/http.h
DEPS_40 += src/paks/http/http.me
DEPS_40 += src/paks/http/httpLib.c
DEPS_40 += src/paks/http/LICENSE.md
DEPS_40 += src/paks/http/package.json
DEPS_40 += src/paks/http/README.md
DEPS_40 += src/paks/me-dev
DEPS_40 += src/paks/me-dev/dev.es
DEPS_40 += src/paks/me-dev/dev.me
DEPS_40 += src/paks/me-dev/LICENSE.md
DEPS_40 += src/paks/me-dev/package.json
DEPS_40 += src/paks/me-dev/README.md
DEPS_40 += src/paks/me-doc
DEPS_40 += src/paks/me-doc/doc.es
DEPS_40 += src/paks/me-doc/doc.me
DEPS_40 += src/paks/me-doc/package.json
DEPS_40 += src/paks/me-package
DEPS_40 += src/paks/me-package/LICENSE.md
DEPS_40 += src/paks/me-package/manifest.me
DEPS_40 += src/paks/me-package/package.es
DEPS_40 += src/paks/me-package/package.json
DEPS_40 += src/paks/me-package/package.me
DEPS_40 += src/paks/me-package/README.md
DEPS_40 += src/paks/mpr
DEPS_40 += src/paks/mpr/LICENSE.md
DEPS_40 += src/paks/mpr/makerom.c
DEPS_40 += src/paks/mpr/manager.c
DEPS_40 += src/paks/mpr/mpr.h
DEPS_40 += src/paks/mpr/mpr.me
DEPS_40 += src/paks/mpr/mprLib.c
DEPS_40 += src/paks/mpr/mprSsl.c
DEPS_40 += src/paks/mpr/package.json
DEPS_40 += src/paks/mpr/README.md
DEPS_40 += src/paks/osdep
DEPS_40 += src/paks/osdep/LICENSE.md
DEPS_40 += src/paks/osdep/osdep.h
DEPS_40 += src/paks/osdep/osdep.me
DEPS_40 += src/paks/osdep/package.json
DEPS_40 += src/paks/osdep/README.md
DEPS_40 += src/paks/pcre
DEPS_40 += src/paks/pcre/LICENSE.md
DEPS_40 += src/paks/pcre/package.json
DEPS_40 += src/paks/pcre/pcre.c
DEPS_40 += src/paks/pcre/pcre.h
DEPS_40 += src/paks/pcre/pcre.me
DEPS_40 += src/paks/pcre/README.md

$(CONFIG)/paks: $(DEPS_40)
	( \
	cd src/paks; \
	mkdir -p "../../$(CONFIG)/paks/esp-angular/0.9.0" ; \
	cp esp-angular/esp-click.js ../../$(CONFIG)/paks/esp-angular/0.9.0/esp-click.js ; \
	cp esp-angular/esp-edit.js ../../$(CONFIG)/paks/esp-angular/0.9.0/esp-edit.js ; \
	cp esp-angular/esp-field-errors.js ../../$(CONFIG)/paks/esp-angular/0.9.0/esp-field-errors.js ; \
	cp esp-angular/esp-fixnum.js ../../$(CONFIG)/paks/esp-angular/0.9.0/esp-fixnum.js ; \
	cp esp-angular/esp-format.js ../../$(CONFIG)/paks/esp-angular/0.9.0/esp-format.js ; \
	cp esp-angular/esp-input-group.js ../../$(CONFIG)/paks/esp-angular/0.9.0/esp-input-group.js ; \
	cp esp-angular/esp-input.js ../../$(CONFIG)/paks/esp-angular/0.9.0/esp-input.js ; \
	cp esp-angular/esp-resource.js ../../$(CONFIG)/paks/esp-angular/0.9.0/esp-resource.js ; \
	cp esp-angular/esp-session.js ../../$(CONFIG)/paks/esp-angular/0.9.0/esp-session.js ; \
	cp esp-angular/esp-titlecase.js ../../$(CONFIG)/paks/esp-angular/0.9.0/esp-titlecase.js ; \
	cp esp-angular/esp.js ../../$(CONFIG)/paks/esp-angular/0.9.0/esp.js ; \
	cp esp-angular/package.json ../../$(CONFIG)/paks/esp-angular/0.9.0/package.json ; \
	mkdir -p "../../$(CONFIG)/paks/esp-angular-mvc/0.9.0" ; \
	cp esp-angular-mvc/package.json ../../$(CONFIG)/paks/esp-angular-mvc/0.9.0/package.json ; \
	mkdir -p "../../$(CONFIG)/paks/esp-angular-mvc/0.9.0/templates" ; \
	mkdir -p "../../$(CONFIG)/paks/esp-angular-mvc/0.9.0/templates/esp-angular-mvc" ; \
	cp esp-angular-mvc/templates/esp-angular-mvc/appweb.conf ../../$(CONFIG)/paks/esp-angular-mvc/0.9.0/templates/esp-angular-mvc/appweb.conf ; \
	mkdir -p "../../$(CONFIG)/paks/esp-angular-mvc/0.9.0/templates/esp-angular-mvc/client" ; \
	mkdir -p "../../$(CONFIG)/paks/esp-angular-mvc/0.9.0/templates/esp-angular-mvc/client/app" ; \
	cp esp-angular-mvc/templates/esp-angular-mvc/client/app/main.js ../../$(CONFIG)/paks/esp-angular-mvc/0.9.0/templates/esp-angular-mvc/client/app/main.js ; \
	mkdir -p "../../$(CONFIG)/paks/esp-angular-mvc/0.9.0/templates/esp-angular-mvc/client/assets" ; \
	cp esp-angular-mvc/templates/esp-angular-mvc/client/assets/favicon.ico ../../$(CONFIG)/paks/esp-angular-mvc/0.9.0/templates/esp-angular-mvc/client/assets/favicon.ico ; \
	mkdir -p "../../$(CONFIG)/paks/esp-angular-mvc/0.9.0/templates/esp-angular-mvc/client/css" ; \
	cp esp-angular-mvc/templates/esp-angular-mvc/client/css/all.css ../../$(CONFIG)/paks/esp-angular-mvc/0.9.0/templates/esp-angular-mvc/client/css/all.css ; \
	cp esp-angular-mvc/templates/esp-angular-mvc/client/css/all.less ../../$(CONFIG)/paks/esp-angular-mvc/0.9.0/templates/esp-angular-mvc/client/css/all.less ; \
	cp esp-angular-mvc/templates/esp-angular-mvc/client/css/app.less ../../$(CONFIG)/paks/esp-angular-mvc/0.9.0/templates/esp-angular-mvc/client/css/app.less ; \
	cp esp-angular-mvc/templates/esp-angular-mvc/client/css/fix.css ../../$(CONFIG)/paks/esp-angular-mvc/0.9.0/templates/esp-angular-mvc/client/css/fix.css ; \
	cp esp-angular-mvc/templates/esp-angular-mvc/client/css/theme.less ../../$(CONFIG)/paks/esp-angular-mvc/0.9.0/templates/esp-angular-mvc/client/css/theme.less ; \
	cp esp-angular-mvc/templates/esp-angular-mvc/client/index.esp ../../$(CONFIG)/paks/esp-angular-mvc/0.9.0/templates/esp-angular-mvc/client/index.esp ; \
	mkdir -p "../../$(CONFIG)/paks/esp-angular-mvc/0.9.0/templates/esp-angular-mvc/client/pages" ; \
	cp esp-angular-mvc/templates/esp-angular-mvc/client/pages/splash.html ../../$(CONFIG)/paks/esp-angular-mvc/0.9.0/templates/esp-angular-mvc/client/pages/splash.html ; \
	cp esp-angular-mvc/templates/esp-angular-mvc/controller-singleton.c ../../$(CONFIG)/paks/esp-angular-mvc/0.9.0/templates/esp-angular-mvc/controller-singleton.c ; \
	cp esp-angular-mvc/templates/esp-angular-mvc/controller.c ../../$(CONFIG)/paks/esp-angular-mvc/0.9.0/templates/esp-angular-mvc/controller.c ; \
	cp esp-angular-mvc/templates/esp-angular-mvc/controller.js ../../$(CONFIG)/paks/esp-angular-mvc/0.9.0/templates/esp-angular-mvc/controller.js ; \
	cp esp-angular-mvc/templates/esp-angular-mvc/edit.html ../../$(CONFIG)/paks/esp-angular-mvc/0.9.0/templates/esp-angular-mvc/edit.html ; \
	cp esp-angular-mvc/templates/esp-angular-mvc/list.html ../../$(CONFIG)/paks/esp-angular-mvc/0.9.0/templates/esp-angular-mvc/list.html ; \
	cp esp-angular-mvc/templates/esp-angular-mvc/model.js ../../$(CONFIG)/paks/esp-angular-mvc/0.9.0/templates/esp-angular-mvc/model.js ; \
	cp esp-angular-mvc/templates/esp-angular-mvc/start.me ../../$(CONFIG)/paks/esp-angular-mvc/0.9.0/templates/esp-angular-mvc/start.me ; \
	mkdir -p "../../$(CONFIG)/paks/esp-html-mvc/0.9.0" ; \
	cp esp-html-mvc/package.json ../../$(CONFIG)/paks/esp-html-mvc/0.9.0/package.json ; \
	mkdir -p "../../$(CONFIG)/paks/esp-html-mvc/0.9.0/templates" ; \
	mkdir -p "../../$(CONFIG)/paks/esp-html-mvc/0.9.0/templates/esp-html-mvc" ; \
	cp esp-html-mvc/templates/esp-html-mvc/appweb.conf ../../$(CONFIG)/paks/esp-html-mvc/0.9.0/templates/esp-html-mvc/appweb.conf ; \
	mkdir -p "../../$(CONFIG)/paks/esp-html-mvc/0.9.0/templates/esp-html-mvc/client" ; \
	mkdir -p "../../$(CONFIG)/paks/esp-html-mvc/0.9.0/templates/esp-html-mvc/client/assets" ; \
	cp esp-html-mvc/templates/esp-html-mvc/client/assets/favicon.ico ../../$(CONFIG)/paks/esp-html-mvc/0.9.0/templates/esp-html-mvc/client/assets/favicon.ico ; \
	mkdir -p "../../$(CONFIG)/paks/esp-html-mvc/0.9.0/templates/esp-html-mvc/client/css" ; \
	cp esp-html-mvc/templates/esp-html-mvc/client/css/all.css ../../$(CONFIG)/paks/esp-html-mvc/0.9.0/templates/esp-html-mvc/client/css/all.css ; \
	cp esp-html-mvc/templates/esp-html-mvc/client/css/all.less ../../$(CONFIG)/paks/esp-html-mvc/0.9.0/templates/esp-html-mvc/client/css/all.less ; \
	cp esp-html-mvc/templates/esp-html-mvc/client/css/app.less ../../$(CONFIG)/paks/esp-html-mvc/0.9.0/templates/esp-html-mvc/client/css/app.less ; \
	cp esp-html-mvc/templates/esp-html-mvc/client/css/theme.less ../../$(CONFIG)/paks/esp-html-mvc/0.9.0/templates/esp-html-mvc/client/css/theme.less ; \
	cp esp-html-mvc/templates/esp-html-mvc/client/index.esp ../../$(CONFIG)/paks/esp-html-mvc/0.9.0/templates/esp-html-mvc/client/index.esp ; \
	mkdir -p "../../$(CONFIG)/paks/esp-html-mvc/0.9.0/templates/esp-html-mvc/client/layouts" ; \
	cp esp-html-mvc/templates/esp-html-mvc/client/layouts/default.esp ../../$(CONFIG)/paks/esp-html-mvc/0.9.0/templates/esp-html-mvc/client/layouts/default.esp ; \
	cp esp-html-mvc/templates/esp-html-mvc/controller-singleton.c ../../$(CONFIG)/paks/esp-html-mvc/0.9.0/templates/esp-html-mvc/controller-singleton.c ; \
	cp esp-html-mvc/templates/esp-html-mvc/controller.c ../../$(CONFIG)/paks/esp-html-mvc/0.9.0/templates/esp-html-mvc/controller.c ; \
	cp esp-html-mvc/templates/esp-html-mvc/edit.esp ../../$(CONFIG)/paks/esp-html-mvc/0.9.0/templates/esp-html-mvc/edit.esp ; \
	cp esp-html-mvc/templates/esp-html-mvc/list.esp ../../$(CONFIG)/paks/esp-html-mvc/0.9.0/templates/esp-html-mvc/list.esp ; \
	cp esp-html-mvc/templates/esp-html-mvc/start.me ../../$(CONFIG)/paks/esp-html-mvc/0.9.0/templates/esp-html-mvc/start.me ; \
	mkdir -p "../../$(CONFIG)/paks/esp-legacy-mvc/0.9.0" ; \
	cp esp-legacy-mvc/package.json ../../$(CONFIG)/paks/esp-legacy-mvc/0.9.0/package.json ; \
	mkdir -p "../../$(CONFIG)/paks/esp-legacy-mvc/0.9.0/templates" ; \
	mkdir -p "../../$(CONFIG)/paks/esp-legacy-mvc/0.9.0/templates/esp-legacy-mvc" ; \
	cp esp-legacy-mvc/templates/esp-legacy-mvc/appweb.conf ../../$(CONFIG)/paks/esp-legacy-mvc/0.9.0/templates/esp-legacy-mvc/appweb.conf ; \
	cp esp-legacy-mvc/templates/esp-legacy-mvc/controller.c ../../$(CONFIG)/paks/esp-legacy-mvc/0.9.0/templates/esp-legacy-mvc/controller.c ; \
	cp esp-legacy-mvc/templates/esp-legacy-mvc/edit.esp ../../$(CONFIG)/paks/esp-legacy-mvc/0.9.0/templates/esp-legacy-mvc/edit.esp ; \
	mkdir -p "../../$(CONFIG)/paks/esp-legacy-mvc/0.9.0/templates/esp-legacy-mvc/layouts" ; \
	cp esp-legacy-mvc/templates/esp-legacy-mvc/layouts/default.esp ../../$(CONFIG)/paks/esp-legacy-mvc/0.9.0/templates/esp-legacy-mvc/layouts/default.esp ; \
	cp esp-legacy-mvc/templates/esp-legacy-mvc/list.esp ../../$(CONFIG)/paks/esp-legacy-mvc/0.9.0/templates/esp-legacy-mvc/list.esp ; \
	cp esp-legacy-mvc/templates/esp-legacy-mvc/migration.c ../../$(CONFIG)/paks/esp-legacy-mvc/0.9.0/templates/esp-legacy-mvc/migration.c ; \
	mkdir -p "../../$(CONFIG)/paks/esp-legacy-mvc/0.9.0/templates/esp-legacy-mvc/src" ; \
	cp esp-legacy-mvc/templates/esp-legacy-mvc/src/app.c ../../$(CONFIG)/paks/esp-legacy-mvc/0.9.0/templates/esp-legacy-mvc/src/app.c ; \
	mkdir -p "../../$(CONFIG)/paks/esp-legacy-mvc/0.9.0/templates/esp-legacy-mvc/static" ; \
	mkdir -p "../../$(CONFIG)/paks/esp-legacy-mvc/0.9.0/templates/esp-legacy-mvc/static/css" ; \
	cp esp-legacy-mvc/templates/esp-legacy-mvc/static/css/all.css ../../$(CONFIG)/paks/esp-legacy-mvc/0.9.0/templates/esp-legacy-mvc/static/css/all.css ; \
	mkdir -p "../../$(CONFIG)/paks/esp-legacy-mvc/0.9.0/templates/esp-legacy-mvc/static/images" ; \
	cp esp-legacy-mvc/templates/esp-legacy-mvc/static/images/banner.jpg ../../$(CONFIG)/paks/esp-legacy-mvc/0.9.0/templates/esp-legacy-mvc/static/images/banner.jpg ; \
	cp esp-legacy-mvc/templates/esp-legacy-mvc/static/images/favicon.ico ../../$(CONFIG)/paks/esp-legacy-mvc/0.9.0/templates/esp-legacy-mvc/static/images/favicon.ico ; \
	cp esp-legacy-mvc/templates/esp-legacy-mvc/static/images/splash.jpg ../../$(CONFIG)/paks/esp-legacy-mvc/0.9.0/templates/esp-legacy-mvc/static/images/splash.jpg ; \
	cp esp-legacy-mvc/templates/esp-legacy-mvc/static/index.esp ../../$(CONFIG)/paks/esp-legacy-mvc/0.9.0/templates/esp-legacy-mvc/static/index.esp ; \
	mkdir -p "../../$(CONFIG)/paks/esp-legacy-mvc/0.9.0/templates/esp-legacy-mvc/static/js" ; \
	cp esp-legacy-mvc/templates/esp-legacy-mvc/static/js/jquery.esp.js ../../$(CONFIG)/paks/esp-legacy-mvc/0.9.0/templates/esp-legacy-mvc/static/js/jquery.esp.js ; \
	cp esp-legacy-mvc/templates/esp-legacy-mvc/static/js/jquery.js ../../$(CONFIG)/paks/esp-legacy-mvc/0.9.0/templates/esp-legacy-mvc/static/js/jquery.js ; \
	mkdir -p "../../$(CONFIG)/paks/esp-server/0.9.0" ; \
	cp esp-server/package.json ../../$(CONFIG)/paks/esp-server/0.9.0/package.json ; \
	mkdir -p "../../$(CONFIG)/paks/esp-server/0.9.0/templates" ; \
	mkdir -p "../../$(CONFIG)/paks/esp-server/0.9.0/templates/esp-server" ; \
	cp esp-server/templates/esp-server/appweb.conf ../../$(CONFIG)/paks/esp-server/0.9.0/templates/esp-server/appweb.conf ; \
	cp esp-server/templates/esp-server/controller.c ../../$(CONFIG)/paks/esp-server/0.9.0/templates/esp-server/controller.c ; \
	cp esp-server/templates/esp-server/migration.c ../../$(CONFIG)/paks/esp-server/0.9.0/templates/esp-server/migration.c ; \
	mkdir -p "../../$(CONFIG)/paks/esp-server/0.9.0/templates/esp-server/src" ; \
	cp esp-server/templates/esp-server/src/app.c ../../$(CONFIG)/paks/esp-server/0.9.0/templates/esp-server/src/app.c ; \
	)

#
#   stop
#
stop: $(DEPS_41)

#
#   installBinary
#
installBinary: $(DEPS_42)
	( \
	cd .; \
	mkdir -p "$(ME_APP_PREFIX)" ; \
	rm -f "$(ME_APP_PREFIX)/latest" ; \
	ln -s "0.9.0" "$(ME_APP_PREFIX)/latest" ; \
	mkdir -p "$(ME_VAPP_PREFIX)/bin" ; \
	cp $(CONFIG)/bin/esp $(ME_VAPP_PREFIX)/bin/esp ; \
	mkdir -p "$(ME_BIN_PREFIX)" ; \
	rm -f "$(ME_BIN_PREFIX)/esp" ; \
	ln -s "$(ME_VAPP_PREFIX)/bin/esp" "$(ME_BIN_PREFIX)/esp" ; \
	cp $(CONFIG)/bin/libappweb.so $(ME_VAPP_PREFIX)/bin/libappweb.so ; \
	cp $(CONFIG)/bin/libest.so $(ME_VAPP_PREFIX)/bin/libest.so ; \
	cp $(CONFIG)/bin/libhttp.so $(ME_VAPP_PREFIX)/bin/libhttp.so ; \
	cp $(CONFIG)/bin/libmpr.so $(ME_VAPP_PREFIX)/bin/libmpr.so ; \
	cp $(CONFIG)/bin/libmprssl.so $(ME_VAPP_PREFIX)/bin/libmprssl.so ; \
	cp $(CONFIG)/bin/libpcre.so $(ME_VAPP_PREFIX)/bin/libpcre.so ; \
	cp $(CONFIG)/bin/ca.crt $(ME_VAPP_PREFIX)/bin/ca.crt ; \
	mkdir -p "$(ME_VAPP_PREFIX)/doc/man/man1" ; \
	cp doc/man/esp.1 $(ME_VAPP_PREFIX)/doc/man/man1/esp.1 ; \
	mkdir -p "$(ME_MAN_PREFIX)/man1" ; \
	rm -f "$(ME_MAN_PREFIX)/man1/esp.1" ; \
	ln -s "$(ME_VAPP_PREFIX)/doc/man/man1/esp.1" "$(ME_MAN_PREFIX)/man1/esp.1" ; \
	)

#
#   start
#
start: $(DEPS_43)

#
#   install
#
DEPS_44 += stop
DEPS_44 += installBinary
DEPS_44 += start

install: $(DEPS_44)

#
#   uninstall
#
DEPS_45 += stop

uninstall: $(DEPS_45)
	( \
	cd .; \
	rm -fr "$(ME_VAPP_PREFIX)" ; \
	rm -f "$(ME_APP_PREFIX)/latest" ; \
	rmdir -p "$(ME_APP_PREFIX)" 2>/dev/null ; true ; \
	)

