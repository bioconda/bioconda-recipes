#!/bin/sh

export LIBRARY_PATH="${PREFIX}/lib:$LIBRARY_PATH"
export CXXFLAGS="-g -Wall -I$PREFIX/include -O3  -I$SRC_DIR/include -I$SRC_DIR/include/zlib -std=c++11 -lstdc++"

sed -i.bak -e '1,5d' Makefile

make CXX=$CXX

mkdir -p $PREFIX/bin/
cp build/bin/gfastats $PREFIX/bin/
chmod +x $PREFIX/bin/gfastats
