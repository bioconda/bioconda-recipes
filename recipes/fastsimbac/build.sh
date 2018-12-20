#!/bin/bash

export CPP_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

cd fastSimBac_linux

sed -i.bak "s|/Users/garychen/software/boost_1_36_0|$PREFIX/include|g" makefile

make all

chmod a+x fastSimBac msformatter

cp fastSimBac $PREFIX/bin
cp msformatter $PREFIX/bin
