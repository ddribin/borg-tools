
PROJECT_NAME = borg-tools
PROJECT_VERSION = 1
FULLNAME = $(PROJECT_NAME)-$(PROJECT_VERSION)

ifeq ($(DRYRUN),1)
  $(info Running with 'rsync -n')
  RSYNC_DRYRUN = -n
else
  RSYNC_DRYRUN =
endif

MKDIR = mkdir -p
RSYNC = rsync --exclude CVS --exclude '*~' $(RSYNC_DRYRUN)
RM = rm -f

PREFIX = /usr/local

STOW_TARGET = $(PREFIX)
STOW_DIR = $(STOW_TARGET)/stow
STOW_PACKAGE_DIR = $(STOW_DIR)/$(PROJECT_NAME)
STOW = stow -t $(STOW_TARGET) -d $(STOW_DIR)

BREW = brew
BREW_CELLAR = $(shell $(BREW) --cellar)
BREW_PROJECT_DIR = "$(BREW_CELLAR)/$(PROJECT_NAME)/$(PROJECT_VERSION)"

INSTALL_TYPE = prefix

.PHONY: build dist install install-prefix install-stow install-brew clean

# Default
all: help

build: FORCE
	$(MKDIR) build/$(FULLNAME)/bin
	$(MKDIR) build/$(FULLNAME)/share
	$(RSYNC) -a --delete bin/ build/$(FULLNAME)/bin

install: install-$(INSTALL_TYPE)

install-prefix: build
	@echo "Installing into $(PREFIX)"
	$(RSYNC) -rl --delete "build/$(FULLNAME)/" "$(PREFIX)"

install-stow: build
	@ if [ -e "$(STOW_DIR)/$(PROJECT_NAME)" ] ; then \
		$(STOW) -D $(PROJECT_NAME); \
	fi
	$(RSYNC) -rl --delete build/$(FULLNAME)/ $(STOW_DIR)/$(PROJECT_NAME)
	$(STOW) $(PROJECT_NAME)

install-brew: build
	@if [ -e "$(BREW_PROJECT_DIR)" ]; then \
		$(BREW) unlink $(PROJECT_NAME); \
	fi
	$(MKDIR) "$(BREW_PROJECT_DIR)"
	$(RSYNC) -rl --delete "build/$(FULLNAME)/" "$(BREW_PROJECT_DIR)"
	$(BREW) link $(PROJECT_NAME)

dist: build FORCE
	$(MKDIR) dist
	tar -zc -C build -f dist/$(FULLNAME).tar.gz $(FULLNAME)

clean:
	$(RM) -r build dist

help:
	@echo "Run 'make DRYRUN=1 ...' to run with 'rsync -n'"
	@echo "Run 'make install' to install into PREFIX"
	@echo "Run 'make install-stow' to install with stow"
	@echo "Run 'make install-brew' to install into Homebrew"
	@echo "Run 'make dist' to build a tar archive"
	@echo "Run 'make build' to create the staging directory for build and dist"
	@echo "Run 'make clean' to cleanup generated files"

FORCE:
