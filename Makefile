
CFLAGS ?= -Wall -Werror
LDFLAGS ?=

PROG := su-exec
SRCS := $(PROG).c

PREFIX := /usr/local
INSTALL_DIR := $(PREFIX)/bin

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
	install -m 0755 $(PROG) $(DESTDIR)$(INSTALL_DIR)

clean:
	rm -f $(PROG) $(PROG)-static $(PROG)-debug
