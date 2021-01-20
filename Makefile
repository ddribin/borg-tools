
PROJECT_NAME = borg-tools
PROJECT_VERSION = 1
FULLNAME = $(PROJECT_NAME)-$(PROJECT_VERSION)

MKDIR = mkdir -p
RSYNC = rsync --exclude CVS --exclude '*~'
RM = rm -f

BREW = brew
BREW_CELLAR = $(shell $(BREW) --cellar)
BREW_PROJECT_DIR = "$(BREW_CELLAR)/$(PROJECT_NAME)/$(PROJECT_VERSION)"

PREFIX = /usr/local

.PHONY: build dist install install-encap install-brew clean

# Default
all: help

build: FORCE
	$(MKDIR) build/$(FULLNAME)/bin
	$(MKDIR) build/$(FULLNAME)/share
	$(RSYNC) -a --delete bin/ build/$(FULLNAME)/bin

install: build
	@echo "Installing into $(PREFIX)"
	$(RSYNC) -rl --delete "build/$(FULLNAME)/" "$(PREFIX)"

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
	@echo "Run 'make install' to install into PREFIX"
	@echo "Run 'make install-brew' to install into Homebrew"
	@echo "Run 'make dist' to build a tar archive"
	@echo "Run 'make build' to create the staging directory for build and dist"
	@echo "Run 'make clean' to cleanup generated files"

FORCE:
