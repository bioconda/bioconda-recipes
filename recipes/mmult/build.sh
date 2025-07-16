#!/bin/bash

export CFLAGS="-I$PREFIX/include -I$PREFIX/include/eigen3"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include

cd "$SRC_DIR"
autoreconf -i
./configure CPPFLAGS="-I${PREFIX}/include -I${PREFIX}/include/eigen3" LDFLAGS="-L${PREFIX}/lib" --prefix=$PREFIX
make
make install -C src
