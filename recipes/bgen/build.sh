#!/bin/bash

set -xe

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3 -std=c++14 -DUSE_BOOST -I${PREFIX}/include"

mkdir -p $PREFIX/bin bgen

tar -xf bgen.tgz --strip-components 1 -C bgen
cd bgen
./waf configure
./waf

cp build/apps/bgenix ${PREFIX}/bin
cp build/apps/cat-bgen ${PREFIX}/bin
cp build/apps/edit-bgen ${PREFIX}/bin