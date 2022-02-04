#!/bin/bash
mkdir -p $PREFIX/bin

export CPATH=${PREFIX}/include

make INCLUDES="-I$PREFIX/include" CFLAGS="-g -Wall -O2 -Wc++-compat" sdust

cp $SRC_DIR/sdust $PREFIX/bin