#!/bin/bash

mkdir -p $PREFIX/bin

mkdir build
cd build
export MPICXX=$PREFIX/bin
cmake . -DCMAKE_INSTALL_PREFIX=$PREFIX/bin ..
make
ls
#make install
#chmod +x Ray
cp Ray $PREFIX/bin
ls $PREFIX/
ls $PREFIX/bin
