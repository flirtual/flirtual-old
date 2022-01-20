export
LDFLAGS     := -static
OBJTYPE     := x86_64
PREFIX      := $(realpath $(dir $(firstword $(MAKEFILE_LIST))))
MANPREFIX   := $(PREFIX)/man
PLAN9       := $(PREFIX)/vendor/9base
YACC        := $(PREFIX)/vendor/9base/yacc/yacc -S
EDIT        := null
GO111MODULE := off

.PHONY: all deps permissions 9base es mawk redis kryptgo bluemonday-cli cgd clean

all: permissions deps

deps: 9base es mawk redis kryptgo bluemonday-cli cgd

9base:
	$(MAKE) -C vendor/9base LDFLAGS=$(LDFLAGS) OBJTYPE=$(OBJTYPE) PREFIX=$(PREFIX) MANPREFIX=$(MANPREFIX) install

es: 9base
	cd vendor/es && ./configure --bindir=$(PREFIX)/bin --mandir=$(MANPREFIX)
	$(MAKE) -C vendor/es install

mawk:
	touch vendor/mawk/array.c vendor/mawk/array.h vendor/mawk/parse.c vendor/mawk/parse.h
	cd vendor/mawk && ./configure --prefix=$(PREFIX) --mandir=$(MANPREFIX) --program-transform-name='s/mawk/awk/'
	$(MAKE) -C vendor/mawk install

redis:
	$(MAKE) -C vendor/redis install

kryptgo:
	go get -u golang.org/x/crypto/bcrypt
	cd vendor/kryptgo && go build -ldflags "-extldflags -static"
	mkdir -p $(PREFIX)/bin && cp vendor/kryptgo/kryptgo $(PREFIX)/bin/

bluemonday-cli:
	go get -u github.com/microcosm-cc/bluemonday
	cd vendor/bluemonday-cli && go build -ldflags "-extldflags -static"
	mkdir -p $(PREFIX)/bin && cp vendor/bluemonday-cli/bluemonday-cli $(PREFIX)/bin/bluemonday

cgd:
	cd vendor/cgd && go build -ldflags "-linkmode external -extldflags -static"
	mkdir -p $(PREFIX)/bin && cp vendor/cgd/cgd $(PREFIX)/bin/

permissions:
	find . $(PREFIX) -type d -exec chmod 2750 {} ';'
	find . $(PREFIX) -type f -exec chmod 640 {} ';'
	chmod 750 vendor/es/configure vendor/mawk/configure $(PREFIX)/app/es/kwerc.es

clean:
	$(MAKE) -C vendor/9base PREFIX=$(PREFIX) MANPREFIX=$(MANPREFIX) uninstall clean
	rm $(PREFIX)/bin/es $(PREFIX)/bin/esdebug $(MANPREFIX)/man1/es.1; $(MAKE) -C vendor/es clean
	$(MAKE) -C vendor/mawk uninstall clean
	$(MAKE) -C vendor/redis uninstall distclean
	rm $(PREFIX)/bin/kryptgo; cd vendor/kryptgo && go clean
	rm $(PREFIX)/bin/bluemonday; cd vendor/bluemonday-cli && go clean
	rm $(PREFIX)/bin/cgd; cd vendor/cgd && go clean
