PACKAGE_NAME = gcc
PACKAGE_VER = 4.9.0
SOURCE_FILE = $(PACKAGE_NAME)-$(PACKAGE_VER).tar.bz2

DEPENDS = ../mpc ../mpfr ../gmp ../../tools/libtool ../isl

BUILD_STYLE = custom

include ../../build.mk

custom_build:
	(set -e; \
	mkdir -p src/build; \
	cd src/build; \
	../$(PACKAGE_NAME)-$(PACKAGE_VER)/configure CFLAGS="$(CFLAGS)" LDFLAGS="$(LDFLAGS)"  --prefix=$(PREFIX) --enable-shared --enable-tls --enable-threads=posix --enable-__cxa_atexit --enable-clocal=gnu --enable-languages=c,c++,fortran --disable-multilib --with-system-zlib ; \
	$(MAKE); \
	)

custom_install:
	(set -e; \
	cd src/build; \
	$(MAKE) install; \
	)

custom_clean:
	@rm -rf src/* .hpcstack_*

