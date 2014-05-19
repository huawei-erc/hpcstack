PACKAGE_NAME = cmake
PACKAGE_VER = 2.8.12.2

DEPENDS = ../autoconf ../automake ../pkg-config

BUILD_STYLE = custom

include ../../build.mk

custom_build:
	(set -e; \
	cd src/$(PACKAGE_NAME)-$(PACKAGE_VER); \
	./bootstrap --prefix=$(PREFIX); \
	$(MAKE); \
	)

custom_install:
	(set -e; \
	cd src/$(PACKAGE_NAME)-$(PACKAGE_VER); \
	$(MAKE) install; \
	)

custom_clean:
	@rm -rf src/* .hpcstack_*

