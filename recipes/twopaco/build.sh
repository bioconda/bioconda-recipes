#!/bin/bash

export CFLAGS="-I${PREFIX}/include"
export CXXFLAGS="-I{$PREFIX}/include"
export LDFLAGS="-L${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib:${LD_LIBRARY_PATH}"
export CPATH=${PREFIX}/include
export C_INCLUDE_PATH=$PREFIX/include

mkdir build 
cd build

cmake ../src
make

cp graphconstructor/twopaco ${PREFIX}/bin/
cp graphdump/graphdump ${PREFIX}/bin/
