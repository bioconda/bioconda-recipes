#!/bin/bash

export CPPFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

if [ "$(uname)" == "Darwin" ]; then
    # clang doesn't accept -fopenmp and there's no clear way around that
    ./configure --prefix=$PREFIX
else
    ./configure --prefix=$PREFIX OPENMP_CFLAGS='-fopenmp' CFLAGS='-DHAVE_OPENMP'
fi
make

mkdir -p $PREFIX/bin
cp $SRC_DIR/src/clustalo $PREFIX/bin/$PKG_NAME
chmod +x $PREFIX/bin/$PKG_NAME
