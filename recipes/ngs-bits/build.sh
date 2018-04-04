#!/bin/bash

#link include and lib folders to allow using htslib
ln -s $PREFIX/include htslib/include
ln -s $PREFIX/lib htslib/lib

#build
make build_tools_release

#remove test files from bin folder
rm -rf bin/out bin/cpp*-TEST bin/tools-TEST

#deploy (lib)
mkdir -p $PREFIX/lib
mv bin/libcpp* $PREFIX/lib/

#deploy (bin)
mkdir -p $PREFIX/bin
mv bin/* $PREFIX/bin/