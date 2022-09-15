#!/bin/bash

# add Configuration and example files to opt
falco=$PREFIX/opt/$PKG_NAME-$PKG_VERSION
mkdir -p $falco
cp -r ./* $falco

#to fix problems with htslib
export C_INCLUDE_PATH=$C_INCLUDE_PATH:${PREFIX}/include
export CPLUS_INCLUDE_PATH=$CPLUS_INCLUDE_PATH:${PREFIX}/include
export LIBRARY_PATH=$LIBRARY_PATH:${PREFIX}/lib
export LD_LIBRARY_PATH=$LIBRARY_PATH:${PREFIX}/lib

cd $falco
./configure --prefix=$falco --enable-hts
make
make install
cd -
mv $falco/bin/falco ./bin
