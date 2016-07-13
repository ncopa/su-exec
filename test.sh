#!/bin/bash
set -e

usage() {
	echo "usage: $1 su-exec-binary"
	echo "   ie: $1 ./su-exec"
}

su_exec="$1"
shift || { usage >&2; exit 1; }

trap '{ set +x; echo; echo FAILED; echo; } >&2' ERR

set -x

dir="$(mktemp -d -t su-exec-test-XXXXXXXXXX)"
base="$(basename "$dir")"
img="su-exec-test:$base"
trap "rm -rf '$dir'" EXIT
cp Dockerfile.test "$dir/Dockerfile"
cp "$su_exec" "$dir/su-exec"
docker build -t "$img" "$dir"
rm -rf "$dir"
trap - EXIT

trap "docker rm -f '$base' > /dev/null; docker rmi -f '$img' > /dev/null" EXIT

docker run -d --name "$base" "$img" su-exec root sleep 1000
sleep 1 # give it plenty of time to get through "su-exec" and into the "sleep"
[ "$(docker top "$base" | wc -l)" = 2 ]
# "docker top" should have only two lines
# -- ps headers and a single line for the single process running in the container
