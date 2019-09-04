#!/bin/bash
export CPATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
rm -rf build
mkdir build
cd build
cmake -DCMAKE_CXX_FLAGS="$CXXFLAGS -DUSE_NEW_CXX" ..
make -j8

binaries="\
simka \
simkaCount \
simkaCountProcess \
simkaMerge \
simkaMin \
"

mkdir -p $PREFIX/bin/
for i in $binaries; do cp $SRC_DIR/build/bin/$i $PREFIX/bin/; done
for i in $binaries; do chmod +x $PREFIX/bin/$i; done

cp $SRC_DIR/simkaMin/*.py $PREFIX/bin/
