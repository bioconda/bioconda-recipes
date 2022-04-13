#!/bin/sh

export LIBRARY_PATH="${PREFIX}/lib:$LIBRARY_PATH"
export CFLAGS="-g -Wall -I$PREFIX/include -O3  -I$SRC_DIR/include  -std=c++11 -lstdc++"

sed -i.bak -e '1,4d' Makefile

make CC=$CXX

mkdir -p $PREFIX/bin/
cp build/bin/gfastats $PREFIX/bin/
chmod +x $PREFIX/bin/gfastats
