# su-exec
switch user and group id, setgroups and exec

## Purpose

This is a simple tool that will simply execute a program with different
privileges. The program will be exceuted directly and not run as a child,
like su and sudo does, which avoids TTY and signal issues (see below).

Notice that su-exec depends on being run by the root user, non-root
users do not have permission to change uid/gid.

## Usage

```shell
su-exec user-spec command [ arguments... ]
```

`user-spec` is either a user name (e.g. `nobody`) or user name and group
name separated with colon (e.g. `nobody:ftp`). Numeric uid/gid values
can be used instead of names. Example:

```shell
$ su-exec apache:1000 /usr/sbin/httpd -f /opt/www/httpd.conf
```

Alternatively `user-spec` can be `-e` or `--env` to enable setting the user/group from environment variables instead:

```shell
$ export SUID=123
$ export SGID=456
$ su-exec --env id
uid=123 gid=456 groups=456
```

## Installation

To compile and install run

```shell
make
make install
```

which will install under `/usr/local`. To install somewhere else you can use the
`PREFIX` variable, like `make install PREFIX=$HOME/software`.

## TTY & parent/child handling

Notice how `su` will make `ps` be a child of a shell while `su-exec`
just executes `ps` directly.

```shell
$ docker run -it --rm alpine:edge su postgres -c 'ps aux'
PID   USER     TIME   COMMAND
    1 postgres   0:00 ash -c ps aux
   12 postgres   0:00 ps aux
$ docker run -it --rm -v $PWD/su-exec:/sbin/su-exec:ro alpine:edge su-exec postgres ps aux
PID   USER     TIME   COMMAND
    1 postgres   0:00 ps aux
```

## Why reinvent gosu?

This does more or less exactly the same thing as [gosu](https://github.com/tianon/gosu)
but it is only 10kb instead of 1.8MB.

