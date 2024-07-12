#!/bin/sh
set -e
rm -rf build
mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release ..
make
cpack
mv -f *.rpm *.deb .. 2>/dev/null || true
