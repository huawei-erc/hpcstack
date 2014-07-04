PACKAGE_NAME = boost
PACKAGE_VER = 1_55_0
SOURCE_FILE = $(PACKAGE_NAME)_$(PACKAGE_VER).tar.bz2

DEPENDS = ../../tools/libtool ../../compilers/gcc

BUILD_STYLE = custom
SRC_DIR = src/$(PACKAGE_NAME)_$(PACKAGE_VER)

include ../../build.mk

custom_build:
	(set -e; \
	cd src/$(PACKAGE_NAME)_$(PACKAGE_VER); \
	./bootstrap.sh --with-toolset=gcc --prefix=$(PREFIX); \
	./b2 -j25 cxxflags="$(CFLAGS)" linkflags="$(LDFLAGS)"; \
	)

custom_install:
	(set -e; \
	cd src/$(PACKAGE_NAME)_$(PACKAGE_VER) ; \
	./b2 install; \
	)

custom_clean:
	@rm -rf src/* .hpcstack_*

