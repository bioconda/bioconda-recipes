#!/bin/sh

export CFLAGS="$CFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
export CPATH=${PREFIX}/include
ls -l src

cmake .
make

mkdir -p $PREFIX/bin
cp $SRC_DIR/emerald $PREFIX/bin
