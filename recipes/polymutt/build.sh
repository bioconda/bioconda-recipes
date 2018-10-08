#!/bin/sh

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include

make

cp ${SRC_DIR}/bin/polymutt $PREFIX/bin/polymutt
