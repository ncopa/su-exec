# Simple makefile for su-exec

PREFIX ?= /usr/local
BINDIR ?= $(PREFIX)/bin

CFLAGS ?= -Wall -Werror -s
# CFLAGS ?= -Wall -Werror -g
LDFLAGS ?=

PROG := su-exec
SRCS := $(PROG).c

all: $(PROG)

$(PROG): $(SRCS)
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

$(PROG)-static: $(SRCS)
	$(CC) $(CFLAGS) -o $@ $^ -static $(LDFLAGS)

clean:
	rm -f $(PROG) $(PROG)-static

install: all
	cp -pv $(PROG) $(BINDIR)/$(PROG) && chown root:root $(BINDIR)/$(PROG)

install-gosu: all
	cp -pv $(PROG) $(BINDIR)/gosu && chown root:root $(BINDIR)/gosu

# ---------------------------------------------------------------------------
