#!/bin/bash

export CPPFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

./configure --prefix=$SRC_DIR
make
./configure --prefix=$SRC_DIR --program-suffix=MP OPENMP_CFLAGS='-fopenmp' CFLAGS='-DHAVE_OPENMP'
make

mkdir -p $PREFIX/bin
cp $SRC_DIR/src/clustalo $PREFIX/bin/clustalo
cp $SRC_DIR/src/clustaloMP $PREFIX/bin/clustaloMP
chmod +x $PREFIX/bin/clustalo
chmod +x $PREFIX/bin/clustaloMP
