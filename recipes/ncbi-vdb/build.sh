#!/bin/bash

mkdir -p $PREFIX/src/

cp -r $SRC_DIR $PREFIX/src/ncbi-vdb

cd $PREFIX/src/ncbi-vdb

./configure --prefix=$PREFIX/ --build-prefix=$PREFIX/share/ncbi  --with-ngs-sdk-prefix=$PREFIX
make install
