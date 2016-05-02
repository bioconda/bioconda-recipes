#!/bin/bash

NCBI_SRC=$PREFIX/src/ncbi

mkdir -p $NCBI_SRC
cp -r $SRC_DIR $NCBI_SRC/ncbi-vdb
cd $NCBI_SRC/ncbi-vdb

./configure --prefix=$PREFIX/ \
	--build-prefix=$PREFIX/share/ncbi \
	--with-ngs-sdk-prefix=$PREFIX
make install
