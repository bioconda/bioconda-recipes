#!/bin/bash

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include


echo "Compiling covtobed"
$CXX -std=c++11 *.cpp -I${PREFIX}/include/bamtools  ${PREFIX}/lib/libbamtools.a -o covtobed -lz

echo "Moving binary"
mkdir -p ${PREFIX}/bin
mv covtobed ${PREFIX}/bin/
