
CFLAGS ?= -Wall -Werror -g
LDFLAGS ?=

PROG := su-exec
SRCS := $(PROG).c

all: $(PROG)

$(PROG): $(SRCS)
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

$(PROG)-static: $(SRCS)
	$(CC) $(CFLAGS) -o $@ $^ -static $(LDFLAGS)

test: $(PROG)
	./test.sh ./su-exec

clean:
	rm -f $(PROG) $(PROG)-static
