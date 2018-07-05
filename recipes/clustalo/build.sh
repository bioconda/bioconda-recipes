#!/bin/bash

export CPPFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

if [ "$(uname)" == "Darwin" ]; then
    ./configure --prefix=$SRC_DIR OPENMP_CFLAGS='-fopenmp=libiomp5' CFLAGS='-DHAVE_OPENMP'
else
    ./configure --prefix=$SRC_DIR OPENMP_CFLAGS='-fopenmp' CFLAGS='-DHAVE_OPENMP'
fi
make

mkdir -p $PREFIX/bin
cp $SRC_DIR/src/clustalo $PREFIX/bin/$PKG_NAME
chmod +x $PREFIX/bin/$PKG_NAME
