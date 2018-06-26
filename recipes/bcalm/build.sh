#!/bin/bash

export CPLUS_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

mkdir -p $PREFIX/bin

rm -Rf gatb-core
git clone -n https://github.com/GATB/gatb-core
cd gatb-core
git checkout da36e81667f46fd34aa274e792d280a6e4b1e624
cd ..

mkdir build
cd build
cmake -DCMAKE_PREFIX_PATH=$PREFIX -DCMAKE_INSTALL_PREFIX=${PREFIX} ..
make
cp bcalm $PREFIX/bin
