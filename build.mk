# HPCStack Build System
# Copyright (C) 2014 Huawei
# Author: Lauri Leukkunen
# License: MIT

ifeq ($(TOPDIR),)
TOPDIR = $(shell if [ -f ../build.mk ]; then cd ..; pwd; fi)
endif
ifeq ($(TOPDIR),)
TOPDIR = $(shell if [ -f ../../build.mk ]; then cd ../..; pwd; fi)
endif
CACHE_DIR = $(TOPDIR)/cache

-include $(TOPDIR)/.hpcstack_local

dirs ?= 
PREFIX ?= /opt/hpcstack
HPCSTACK_DIR ?= $(PREFIX)
PACKAGE_NAME ?=
PACKAGE_VER ?=
DEPENDS ?=
BUILD_DEPENDS ?=
SRC_DIR ?= src/$(PACKAGE_NAME)-$(PACKAGE_VER)
SOURCE_FILE ?= $(PACKAGE_NAME)-$(PACKAGE_VER).tar.gz
SOURCE_URL ?= http://ftp.gnu.org/pub/gnu/$(PACKAGE_NAME)/$(SOURCE_FILE)
BUILD_STYLE ?= autotools
FETCH ?= wget

PATH := $(HPCSTACK_DIR)/bin:$(PATH)
export PATH

CFLAGS = -I$(HPCSTACK_DIR)/include -I/usr/include
LDFLAGS = -L$(HPCSTACK_DIR)/lib -Wl,-rpath,$(HPCSTACK_DIR)/lib
CPPFLAGS = -I$(HPCSTACK_DIR)/include

.DEFAULT_GOAL := build

$(dirs):
	$(MAKE) -C $@ build

src_full_path := $(foreach f, $(SOURCE_FILE), $(CACHE_DIR)/$(f))
depends_targets = $(addsuffix .depends,$(DEPENDS))

.PHONY: $(depends_targets) depends $(dirs)

$(src_full_path):
	@mkdir -p $(CACHE_DIR)
	$(FETCH) $(SOURCE_URL)

$(depends_targets): %.depends:
	@flock -e $*/.hpcstack_lock -c '$(MAKE) -C $* install'

depends: $(depends_targets)

.hpcstack_depends:
	$(MAKE) depends
	@touch .hpcstack_depends

.hpcstack_extract: $(src_full_path) .hpcstack_depends
	@mkdir -p src
	tar xf $< -C src;
	@touch .hpcstack_extract

.hpcstack_sources: .hpcstack_extract
	@(set -e; cd $(SRC_DIR); \
	if [ ! -d ../../patches ]; then exit 0; fi; \
	for f in $$(find ../../patches -name *.patch | sort); do \
		patch < $$f; \
	done)
	@touch .hpcstack_sources

.hpcstack_autotools_autogen: .hpcstack_sources
	(set -e; cd $(SRC_DIR); \
	if [ -x ./autogen.sh ]; then ./autogen.sh; fi;)
	@touch .hpcstack_autotools_autogen

.hpcstack_autotools_config: .hpcstack_autotools_autogen
	(set -e; cd $(SRC_DIR); \
	./configure CFLAGS="$(CFLAGS)" LDFLAGS="$(LDFLAGS)" --prefix=$(PREFIX))
	@touch .hpcstack_autotools_config

.hpcstack_autotools_build: .hpcstack_autotools_config
	$(MAKE) -C $(SRC_DIR) 
	@touch .hpcstack_autotools_build

.hpcstack_autotools_install: .hpcstack_autotools_build
	$(MAKE) -C $(SRC_DIR) install
	@touch .hpcstack_autotools_install

.hpcstack_autotools_clean:
	@rm -rf src/* .hpcstack_*

ifeq ("$(BUILD_STYLE)","autotools")
build: .hpcstack_autotools_build

install: .hpcstack_autotools_install

clean: .hpcstack_autotools_clean
endif
ifeq ("$(BUILD_STYLE)","custom")
.hpcstack_custom_build:
	$(MAKE) custom_build
	@touch .hpcstack_custom_build

.hpcstack_custom_install:
	$(MAKE) custom_install
	@touch .hpcstack_custom_install

.hpcstack_custom_clean:
	$(MAKE) custom_clean

build: .hpcstack_custom_build

install: .hpcstack_custom_install

clean: .hpcstack_custom_clean
endif

##########################################
### Category Related Build Stuff Below ###
##########################################

ifeq ("$(BUILD_STYLE)","category")
build_targets = $(patsubst %,build-%,$(dirs))
clean_targets = $(patsubst %,clean-%,$(dirs))

$(build_targets): build-%:
	@flock -e $*/.hpcstack_lock -c '$(MAKE) -C $* install'

$(clean_targets): clean-%:
	$(MAKE) -C $* clean

build: $(build_targets)

clean: $(clean_targets)
endif

