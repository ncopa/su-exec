The Makefile for `su-exec` is very small and very simple.

1. `make` or `make all`
2. Copy the resulting `su-exec` executable to your preferred location.

The `make install` target supports copying. By default, it copies to
`/usr/local/bin` but this can be controlled with the corresponding
`PREFIX` or `BINDIR` make variables.
You will mostly likely require root permission.

For example,
```
$ make PREFIX=/usr install
$ make BINDIR=/usr/sbin install
```

If you are replacing `gosu` with `su-exec` there is a target for that:
```
$ make PREFIX=/usr install-gosu
$ make BINDIR=/usr/sbin install-gosu
```
