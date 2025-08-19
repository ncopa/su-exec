#!/bin/sh
BASE_DIR="$(git rev-parse --show-toplevel)"
DIST_DIR="$BASE_DIR/dist"

BUILD_DATE="$(date +%Y-%m-%dT%T%z)"
BUILD_REVISION="$(git rev-parse HEAD)"

TAG="shinsenter/su-exec:latest"
ALIAS="ghcr.io/shinsenter/su-exec:latest"

PLATFORMS=(
	linux/386
	linux/amd64
	linux/arm/v6
	linux/arm/v7
	linux/arm64/v8
	linux/ppc64le
	linux/riscv64
	linux/s390x
)

prepare_dist() {
	mkdir -p "$DIST_DIR"
	rm -rf "$DIST_DIR"/*
}

build_su_exec() {
	docker buildx build -t "$TAG" \
		--provenance=true --sbom=true \
		--attest type=sbom \
		--platform "$(IFS=,; echo "${PLATFORMS[*]}")" \
		--build-arg BUILD_NAME=su-exec \
		--build-arg BUILD_DATE="$BUILD_DATE" \
		--build-arg BUILD_REVISION="$BUILD_REVISION" \
		--output "$DIST_DIR" \
		-f "$BASE_DIR/Dockerfile" \
		-- "$BASE_DIR"
}

collect_binaries() {
	for dir in "$DIST_DIR"/linux_*; do
		[ -d "$dir" ] || continue
		arch="${dir##*/linux_}"
		bin="$DIST_DIR/su-exec-$arch"
		if [ -f "$dir/su-exec" ]; then
			mv "$dir/su-exec" "$bin" && chmod +x "$bin"
		fi
		rm -rf "$dir"
	done

	ls -lah "$DIST_DIR"
}

push_images() {
	docker tag "$TAG" "$ALIAS"
	docker push "$TAG"
	docker push "$ALIAS"
}

############################################################

set -e
prepare_dist
build_su_exec || exit 1
bash "$BASE_DIR/test.sh" || exit 1

collect_binaries
[ "$1" = "push" ] && push_images

echo "✅ Done!"
