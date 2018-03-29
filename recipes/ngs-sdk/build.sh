#!/bin/bash

####
# build ngs-sdk
####

# First configure fails
# See: https://github.com/ncbi/ngs/issues/1
export ROOT=$PREFIX
./configure --prefix=$PREFIX/ --build=$PREFIX/share/ncbi
make -C ngs-sdk
make -C ngs-sdk install
make -C ngs-sdk test


