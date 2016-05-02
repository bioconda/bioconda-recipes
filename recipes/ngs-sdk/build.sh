#!/bin/bash

mkdir -p $PREFIX/src/

cp -r $SRC_DIR $PREFIX/src/ngs-sdk

cd $PREFIX/src/ngs-sdk

# First configure fails
# See: https://github.com/ncbi/ngs/issues/1
./configure --prefix=$PREFIX/ --build-prefix=$PREFIX/share/ncbi
make -C ngs-sdk 

./configure --prefix=$PREFIX/ --build-prefix=$PREFIX/share/ncbi
make -C ngs-sdk install
