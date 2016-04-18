#!/bin/bash
set -e
cd "${0%/*}"


trap '{ set +x; echo; echo FAILED; echo; } >&2' ERR

set -x

dir="$(mktemp -d -t gosu-test-XXXXXXXXXX)"
base="$(basename "$dir")"
img="gosu-test:$base"
trap "rm -rf '$dir'" EXIT
cp Dockerfile.test "$dir/Dockerfile"
cp ../out/*.deb "$dir"
docker build -t "$img" "$dir"
rm -rf "$dir"
trap - EXIT

trap "docker rm -f '$base' > /dev/null; docker rmi -f '$img' > /dev/null" EXIT

docker run -d --name "$base" "$img" su-exec root sleep 1000
sleep 1 # give it plenty of time to get through "gosu" and into the "sleep"
[ "$(docker top "$base" | wc -l)" = 2 ]
# "docker top" should have only two lines
# -- ps headers and a single line for the single process running in the container
