#!/bin/bash
export CPATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
rm -rf build
mkdir build
cd build
cmake ..
make -j8

binaries="\
simka \
simkaCount \
simkaCountProcess \
simkaMerge \
"

for i in $binaries; do cp $SRC_DIR/build/bin/$i $PREFIX/bin/$i; done
for i in $binaries; do chmod +x $PREFIX/bin/$i; done