#!/bin/bash

set -xe

export CFLAGS="-I$PREFIX/include -O3"
export LDFLAGS="-L$PREFIX/lib"
export CPATH="${PREFIX}/include"
export CXXFLAGS="-I${PREFIX}/include -O3 -std=c++17"
export CPPFLAGS="-isystem/${PREFIX}/include"

./configure --prefix=${PREFIX} --with-sparsehash="${PREFIX}" --with-sdsl="${PREFIX}" --disable-dependency-tracking --disable-silent-rules

make -j ${CPU_COUNT}
make install
