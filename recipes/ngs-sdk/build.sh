#!/bin/bash

NCBI_SRC=$PREFIX/src/ncbi

mkdir -p $NCBI_SRC
cp -r $SRC_DIR $NCBI_SRC/ngs-sdk
cd $NCBI_SRC

# First configure fails
# See: https://github.com/ncbi/ngs/issues/1
./configure --prefix=$PREFIX/ --build-prefix=$PREFIX/share/ncbi
make -C ngs-sdk 

./configure --prefix=$PREFIX/ --build-prefix=$PREFIX/share/ncbi
make -C ngs-sdk install
