
CFLAGS ?= -Wall -Werror
LDFLAGS ?=

PROG := su-exec
SRCS := $(PROG).c

all: $(PROG)

$(PROG): $(SRCS)
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)
	strip $@

$(PROG)-static: $(SRCS)
	$(CC) $(CFLAGS) -o $@ $^ -static $(LDFLAGS)
	strip $@

$(PROG)-debug: $(SRCS)
	$(CC) -g $(CFLAGS) -o $@ $^ $(LDFLAGS)

clean:
	rm -f $(PROG) $(PROG)-static $(PROG)-debug
