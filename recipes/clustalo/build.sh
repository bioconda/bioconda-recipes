#!/bin/bash

export CPPFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

./configure --prefix=$SRC_DIR OPENMP_CFLAGS='-fopenmp' CFLAGS='-DHAVE_OPENMP'
make

mkdir -p $PREFIX/bin
cp $SRC_DIR/src/clustalo $PREFIX/bin/$PKG_NAME
chmod +x $PREFIX/bin/$PKG_NAME
