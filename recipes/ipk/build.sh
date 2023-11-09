#!/bin/bash
set -ex

export CPLUS_INCLUDE_PATH=${PREFIX}/include
export CPP_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/lib

echo $PREFIX
cmake .
mkdir release-build
pushd release-build
cmake -DHASH_MAP=USE_TSL_ROBIN_MAP -DCMAKE_CXX_FLAGS="-O3" ..
make -j4
ls ../
popd
ls .

cp bin/ipk-aa $PREFIX/ipk-aa
cp bin/ipk-aa-pos $PREFIX/ipk-aa-pos
cp bin/ipk-dna $PREFIX/ipk-dna

chmod +x $PREFIX/bin/ipk-*
