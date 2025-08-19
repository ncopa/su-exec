# su-exec

Switch user and group, then exec.

## Introduction

`su-exec` is a very minimal re-write of
[`gosu`](https://github.com/tianon/gosu) in C, making for a much smaller binary.

This is a simple tool that will simply execute a program with different privileges.
The program will be executed directly and not run as a child,
like su and sudo does, which avoids TTY and signal issues.

Notice that su-exec depends on being **run by the root user**,
non-root users do not have permission to change uid/gid.

## Installation Using Docker

```Dockerfile
FROM <base-image>

COPY --from=shinsenter/su-exec:latest --chown=root:root --chmod=4755 /su-exec /usr/sbin/su-exec
```

## Usage

```shell
su-exec user-spec command [ arguments... ]
```

`user-spec` is either a user name (e.g. `nobody`)
or user name and group name separated with colon (e.g. `www-data:www-data`).
Numeric uid/gid values can be used instead of names.

For example:

```shell
su-exec tianon bash
su-exec nobody:root bash -c 'whoami && id'
su-exec 1000:1 id
```

## Supported platforms
- linux/386
- linux/amd64
- linux/arm/v6
- linux/arm/v7
- linux/arm64/v8
- linux/ppc64le
- linux/riscv64
- linux/s390x
