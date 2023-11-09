#!/bin/bash
set -ex

export CPLUS_INCLUDE_PATH=${PREFIX}/include
export CPP_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include

#to ensure zlib location
export CFLAGS="$CFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/lib

echo "PREFIX:" ${PREFIX}
cmake .
echo "CMAKE PASSED"
mkdir release-build
pushd release-build
cmake -DHASH_MAP=USE_TSL_ROBIN_MAP -DCMAKE_CXX_FLAGS="-O3" ..
echo "CMAKE PASSED"
echo "SRC_DIR:" ${SRC_DIR}
pwd
ls .
ls ..
ls ${SRC_DIR}
cmake --build . --target all
ls ../
popd
ls .

cp release-build/ipk-aa $PREFIX/ipk-aa
cp release-build/ipk-aa-pos $PREFIX/ipk-aa-pos
cp release-build/ipk-dna $PREFIX/ipk-dna

chmod +x $PREFIX/bin/ipk-*
