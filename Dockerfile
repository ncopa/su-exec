# syntax=docker/dockerfile:1
ARG BUILDKIT_SBOM_SCAN_CONTEXT=true
ARG BUILDKIT_SBOM_SCAN_STAGE=true

############################################################
FROM alpine:latest AS build
ARG  BUILD_NAME TARGETARCH
RUN --mount=type=bind,source=.,target=/opt,rw <<'BUILD'
set -e
target="/dist/$BUILD_NAME-$TARGETARCH"
mkdir -p $(dirname "$target")
cd /opt/src
apk update && apk add gcc musl-dev
gcc -std=gnu99 -Os -Wall -Wextra -pedantic -s -o "$target" su-exec.c -static
strip --strip-all --strip-debug "$target"
BUILD

############################################################
FROM scratch
ARG  BUILD_NAME TARGETARCH
COPY --from=build --chown=root:root --chmod=755 \
	"/dist/$BUILD_NAME-$TARGETARCH" \
	"/$BUILD_NAME"

############################################################
ARG   BUILD_DATE BUILD_REVISION
LABEL org.opencontainers.image.title="shinsenter/su-exec"
LABEL org.opencontainers.image.description="Switch user and group, then exec."
LABEL org.opencontainers.image.authors="Mai Nhut Tan <shin@shin.company>"
LABEL org.opencontainers.image.created="$BUILD_DATE"
LABEL org.opencontainers.image.vendor="Docker Hub"
LABEL org.opencontainers.image.documentation="https://hub.docker.com/r/shinsenter/su-exec"
LABEL org.opencontainers.image.url="https://hub.docker.com/r/shinsenter/su-exec/tags"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.source="https://github.com/shinsenter/su-exec"
LABEL org.opencontainers.image.revision="$BUILD_REVISION"
