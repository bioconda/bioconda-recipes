#!/bin/bash

export CC=${PREFIX}/bin/gcc
export CXX=${PREFIX}/bin/g++

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"

./configure
make


sed -i 's/usr\/bin\/python/usr\/bin\/env python/g' script/*py

mkdir -p ${PREFIX}/bin

cp bin/* ${PREFIX}/bin
cp script/*py ${PREFIX}/bin
cp script/validate* ${PREFIX}/bin
