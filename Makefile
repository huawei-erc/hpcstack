
-include .local

PREFIX ?= /opt/hpcstack

TOPDIR = $(CURDIR)
export TOPDIR

dirs = tools


default: build

all: build
	@echo "Build complete"

clean_targets := $(addsuffix .clean,$(dirs))
build_targets := $(addsuffix .build,$(dirs))

.PHONY: $(clean_targets) $(build_targets) $(dirs) all build clean purge

$(build_targets): %.build:
	$(MAKE) -C $*

$(clean_targets): %.clean:
	$(MAKE) -C $* clean

build: $(build_targets)
	@echo Build complete

clean: $(clean_targets)
	@echo Clean complete

purge: clean
	@rm -rf $(PREFIX)
