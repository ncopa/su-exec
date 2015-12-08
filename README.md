# su-exec
switch user and group id, setgroups and exec

This is a simple tool that will simply execute a program with different
privileges. The program will not run as a child, like su and sudo, so we
work around TTY and signal issues.


```console
$ docker run -it --rm alpine:edge su -c 'ps aux'
PID   USER     TIME   COMMAND
    1 root       0:00 ash -c ps aux
   12 root       0:00 ps aux
$ docker run -it --rm -v $PWD/su-exec:/sbin/su-exec:ro alpine:edge su-exec  root ps aux
PID   USER     TIME   COMMAND
    1 root       0:00 ps aux
```

## Why reinvent gosu?

This does more or less exactly the same thing as `gosu` but it is only 10kb instead of 1.8MB.

