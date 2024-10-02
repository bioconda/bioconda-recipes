#!/bin/bash
set -ex

mkdir -p "$PREFIX/bin"

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3"
export CXXFLAGS="${CXXFLAGS} -O3 -I${PREFIX}/include"

# on osx we remove the built-in boost and make sure todepend on the system boost
pushd src
if [ "$(uname)" == "Darwin" ]; then
   rm -rf ./canu/src/utgcns/libboost/
fi
make clean && make -j$CPU_COUNT
popd

cp -rf bin/* $PREFIX/bin/
cp -rf lib/* $PREFIX/lib/
