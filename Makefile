
CFLAGS ?= -Wall -Werror
LDFLAGS ?=

PROG := su-exec
SRCS := $(PROG).c
INCS := license.inc

PREFIX := /usr/local
INSTALL_DIR := $(PREFIX)/bin
MAN_DIR := $(PREFIX)/share/man/man8

all: $(PROG)

license.inc: LICENSE
	xxd -i $^ > $@

$(PROG): $(SRCS) $(INCS)
	$(CC) $(CFLAGS) -o $@ $(SRCS) $(LDFLAGS)
	strip $@

$(PROG)-static: $(SRCS) $(INCS)
	$(CC) $(CFLAGS) -o $@ $(SRCS) -static $(LDFLAGS)
	strip $@

$(PROG)-debug: $(SRCS) $(INCS)
	$(CC) -g $(CFLAGS) -o $@ $(SRCS) $(LDFLAGS)

install:
	install -d 0755 $(DESTDIR)$(INSTALL_DIR)
	install -m 0755 $(PROG) $(DESTDIR)$(INSTALL_DIR)
	install -d 0755 $(DESTDIR)$(MAN_DIR)
	install -m 0644 su-exec.1 $(DESTDIR)$(MAN_DIR)

clean:
	rm -f $(PROG) $(PROG)-static $(PROG)-debug $(INCS)

