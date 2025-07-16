#!/bin/bash

export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

cd libs/phylogeny
sed -i.bak 's/CXX=g++//' Makefile
make #CXX=$CXX CC=$CC

cd ../../programs/gainLoss
sed -i.bak 's/CXX=g++//' ../Makefile.generic
make #CXX=$CXX CC=$CC

mkdir -p $PREFIX/bin
cp gainLoss $PREFIX/bin
