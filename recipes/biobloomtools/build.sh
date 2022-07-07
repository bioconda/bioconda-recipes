#!/bin/bash

export CFLAGS="-I$PREFIX/include -O3"
export LDFLAGS="-L$PREFIX/lib"
export CPATH="${PREFIX}/include"
export CXXFLAGS="-I${PREFIX}/include -O3"
export CPPFLAGS="-isystem/${PREFIX}/include"

./configure --prefix=${PREFIX} --with-sparsehash="${PREFIX}" --with-sdsl="${PREFIX}" --disable-dependency-tracking --disable-silent-rules

make
make install
