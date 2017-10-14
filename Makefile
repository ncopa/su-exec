
CFLAGS ?= -Wall -Werror -g
LDFLAGS ?=

PROG := su-exec
SRCS := $(PROG).c

PREFIX := /usr/local
INSTALL_DIR := $(PREFIX)/bin

all: $(PROG)

$(PROG): $(SRCS)
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

$(PROG)-static: $(SRCS)
	$(CC) $(CFLAGS) -o $@ $^ -static $(LDFLAGS)

install:
	install -m 0755 $(PROG) $(INSTALL_DIR)

clean:
	rm -f $(PROG) $(PROG)-static
