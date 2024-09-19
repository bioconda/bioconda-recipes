#!/bin/sh

export LIBRARY_PATH="${PREFIX}/lib:$LIBRARY_PATH"
export CXXFLAGS="-g -Wall -I$PREFIX/include -O3  -I$SRC_DIR/include -I$SRC_DIR/include/zlib -std=gnu++14 -lstdc++"

git submodule update --init --recursive

make -j CXX=$CXX

mkdir -p $PREFIX/bin/
cp build/bin/gfastats $PREFIX/bin/
chmod +x $PREFIX/bin/gfastats
