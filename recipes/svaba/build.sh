#!/bin/bash
set -eu -o pipefail

export LIBS="-lm ${PREFIX}/lib/libz.a"

./configure
make CC=${CC} CXX=${CXX} CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}"
make install

mkdir -p ${PREFIX}/bin
cp bin/svaba ${PREFIX}/bin/
