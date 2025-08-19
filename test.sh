#!/bin/sh
BASE_DIR="$(git rev-parse --show-toplevel)"
RESULTS="$BASE_DIR/test-results.txt"
trap 'kill 0' SIGINT

platforms=(
	linux/amd64
	linux/arm/v7
	linux/arm64/v8
)
joined="$(IFS=, ; echo "${platforms[*]}")"
source="shinsenter/su-exec:latest"

template () {
	local distro="$1"
	cat <<Dockerfile
FROM $distro
COPY --from=$source --chown=root:root --chmod=4755 /su-exec /usr/sbin/su-exec
RUN  if [ "\$(su-exec nobody whoami)" != "nobody" ]; then exit 1; fi
Dockerfile
}

date >"$RESULTS"
while read distro; do
	tag="testing/su-exec-$distro"
	template "$distro" | docker buildx build \
		-t "$tag" --platform "$joined" \
		-
	if [ "$?" -eq "0" ] ; then
		echo $distro OK | tee -a "$RESULTS"
	else
		echo $distro NG | tee -a "$RESULTS"
		exit 1
	fi
done << EOF
alpine:3.9
alpine:3.10
alpine:3.11
alpine:3.12
alpine:3.13
alpine:3.14
alpine:3.15
alpine:3.16
alpine:3.17
alpine:3.18
alpine:3.19
alpine:3.20
alpine:3.21
alpine:3.22
alpine:3
alpine:latest
alpine:edge
debian:jessie
debian:stretch
debian:buster
debian:bullseye
debian:bookworm
debian:trixie
debian:forky
debian:latest
ubuntu:14.04
ubuntu:16.04
ubuntu:17.04
ubuntu:17.10
ubuntu:18.04
ubuntu:18.10
ubuntu:19.04
ubuntu:19.10
ubuntu:20.04
ubuntu:20.10
ubuntu:21.04
ubuntu:21.10
ubuntu:22.04
ubuntu:22.10
ubuntu:23.04
ubuntu:23.10
ubuntu:24.04
ubuntu:24.10
ubuntu:25.04
ubuntu:25.10
ubuntu:latest
ubuntu:rolling
EOF
