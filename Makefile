
CFLAGS ?= -Wall -Werror -g
LDFLAGS ?=

PROG := su-exec
SRCS := $(PROG).c

all: $(PROG)

$(PROG): $(SRCS)
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

$(PROG)-static: $(SRCS)
	$(CC) $(CFLAGS) -o $@ $^ -static $(LDFLAGS)

build-docker: docker-image
	docker run -v $(PWD):/mnt su-exec-build $(PROG)

docker-image:
	docker build -t su-exec-build .

test: $(PROG)
	./test.sh $(PROG)

clean:
	rm -f $(PROG) $(PROG)-static
