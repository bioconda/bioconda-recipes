#!/bin/bash

./configure --prefix=$PREFIX \
	--build-prefix=$PREFIX/share/ncbi/ \
	-with-ncbi-vdb-sources=$PREFIX/src/ncbi-vdb \
	--with-ncbi-vdb-build=$PREFIX/share/ncbi/ncbi-vdb \
	--with-ngs-sdk-prefix=$PREFIX

make install
