CFLAGS  ?= -std=gnu99 -Os -Wall -Wextra -pedantic
LDFLAGS ?=

PROG := su-exec
SRCS := $(PROG).c

all: $(PROG)

$(PROG): $(SRCS)
	$(CC) $(CFLAGS) -s -o $@ $^ $(LDFLAGS) -static

clean: rm -f $(PROG)
