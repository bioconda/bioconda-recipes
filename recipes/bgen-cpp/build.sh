#!/bin/bash

set -euxo pipefail

mkdir -p $PREFIX/bin

export CXXFLAGS="${CXXFLAGS} -std=c++11 -stdlib=libc++ -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

# use an older version of clang
export CC=clang-17 CXX=clang++-17

./waf configure \
    --prefix="${PREFIX}" \
    --bindir="${PREFIX}/bin" \
    --libdir="${PREFIX}/lib"

./waf

cp build/apps/bgenix ${PREFIX}/bin
cp build/apps/cat-bgen ${PREFIX}/bin
cp build/apps/edit-bgen ${PREFIX}/bin