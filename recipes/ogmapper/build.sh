#!/bin/bash

set -xe

make clean

make CONF=Bioconda \
    CC="$CC" \
    CXX="$CXX" \
    CXXFLAGS="-std=c++11 -pthread -include cstring -include cstdint -I$PREFIX/include -I$PREFIX/include/wfa2lib" \
    CFLAGS="-std=c++11 -pthread -I$PREFIX/include -I$PREFIX/include/wfa2lib" \
    LDFLAGS="-L$PREFIX/lib/ -lwfa2cpp -lz -Wl,-rpath,$PREFIX/lib/ $([[ "$OSTYPE" == "darwin"* ]] && echo "-lomp")" \
    build

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/share

cp dist/Bioconda/*/ogmapper $PREFIX/bin
cp -r guiders $PREFIX/share/ogmapper-guiders
