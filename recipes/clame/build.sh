#!/bin/bash

export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

git clone https://github.com/simongog/sdsl-lite.git
cd sdsl-lite
./install.sh
cd ..

cd binning
make
mkdir -p $PREFIX/bin
cp binning $PREFIX/bin
cd ..

cd genFm9
make
cp genFm9 $PREFIX/bin
cd ..

cd mapping
make
cp mapping $PREFIX/bin
cd ..

make
cp clame $PREFIX/bin
