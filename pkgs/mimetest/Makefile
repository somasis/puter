DESTDIR  ?=
prefix   ?= /usr/local
bindir   ?= $(prefix)/bin
datadir  ?= $(prefix)/share
mandir   ?= $(datadir)/man

dev: CFLAGS += -Wall -pedantic
dev: mimetest

all: mimetest

mimetest: mimetest.c
	$(CC) -std=c99 $(CFLAGS) -lmagic $< -o $@

install: mimetest
	install -m0755 -D mimetest   $(DESTDIR)$(bindir)/mimetest
	install -m0644 -D mimetest.1 $(DESTDIR)$(mandir)/man1/mimetest

clean: FRC
	rm -f mimetest

FRC:
