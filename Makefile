# recursxz makefile

VERSION=$(shell ./recursxz --version|perl -pi -e 's/^\D+//; chomp')

ifndef prefix
# This little trick ensures that make install will succeed both for a local
# user and for root. It will also succeed for distro installs as long as
# prefix is set by the builder.
prefix=$(shell perl -e 'if($$< == 0 or $$> == 0) { print "/usr" } else { print "$$ENV{HOME}/.local"}')

# Some additional magic here, what it does is set BINDIR to ~/bin IF we're not
# root AND ~/bin exists, if either of these checks fail, then it falls back to
# the standard $(prefix)/bin. This is also inside ifndef prefix, so if a
# prefix is supplied (for instance meaning this is a packaging), we won't run
# this at all
BINDIR ?= $(shell perl -e 'if(($$< > 0 && $$> > 0) and -e "$$ENV{HOME}/bin") { print "$$ENV{HOME}/bin";exit; } else { print "$(prefix)/bin"}')
endif

BINDIR ?= $(prefix)/bin
DATADIR ?= $(prefix)/share

DISTFILES = COPYING recursxz INSTALL Makefile NEWS README.md recursxz.1

# Install recursxz
install:
	mkdir -p "$(BINDIR)"
	cp recursxz "$(BINDIR)"
	chmod 755 "$(BINDIR)/recursxz"
	[ -e recursxz.1 ] && mkdir -p "$(DATADIR)/man/man1" && cp recursxz.1 "$(DATADIR)/man/man1" || true
localinstall:
	mkdir -p "$(BINDIR)"
	ln -sf $(shell pwd)/recursxz $(BINDIR)/
	[ -e recursxz.1 ] && mkdir -p "$(DATADIR)/man/man1" && ln -sf $(shell pwd)/recursxz.1 "$(DATADIR)/man/man1" || true
# Uninstall an installed recursxz
uninstall:
	rm -f "$(BINDIR)/recursxz" "$(BINDIR)/gpconf" "$(DATADIR)/man/man1/recursxz.1"
	rm -rf "$(DATADIR)/recursxz"
# Clean up the tree
clean:
	rm -f `find|egrep '~$$'`
	rm -f recursxz-*.tar.bz2
	rm -rf recursxz-$(VERSION)
	rm -f recursxz.1
# Verify syntax
test:
	@perl -c recursxz
# Create a manpage from the POD
man:
	pod2man --name "recursxz" --center "" --release "recursxz $(VERSION)" ./recursxz ./recursxz.1
# Create the tarball
distrib: clean test man
	mkdir -p recursxz-$(VERSION)
	cp $(DISTFILES) ./recursxz-$(VERSION)
	tar -jcvf recursxz-$(VERSION).tar.bz2 ./recursxz-$(VERSION)
	rm -rf recursxz-$(VERSION)
	rm -f recursxz.1
