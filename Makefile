
CFLAGS ?= -Wall -Werror
LDFLAGS ?=

PROG := su-exec
SRCS := $(PROG).c

PREFIX := /usr/local
INSTALL_DIR := $(PREFIX)/bin
MAN_DIR := $(PREFIX)/share/man/man8

all: $(PROG)

$(PROG): $(SRCS)
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)
	strip $@

$(PROG)-static: $(SRCS)
	$(CC) $(CFLAGS) -o $@ $^ -static $(LDFLAGS)
	strip $@

$(PROG)-debug: $(SRCS)
	$(CC) -g $(CFLAGS) -o $@ $^ $(LDFLAGS)

install:
	install -d 0755 $(DESTDIR)$(INSTALL_DIR)
	install -m 0755 $(PROG) $(DESTDIR)$(INSTALL_DIR)
	install -d 0755 $(DESTDIR)$(MAN_DIR)
	install -m 0644 su-exec.1 $(DESTDIR)$(MAN_DIR)

clean:
	rm -f $(PROG) $(PROG)-static $(PROG)-debug
