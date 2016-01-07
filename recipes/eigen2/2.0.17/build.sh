#!/bin/sh
mkdir -p $PREFIX/unpacked_source
cp -r * $PREFIX/unpacked_source
mkdir -p build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=$PREFIX/eigen2/
make
make install
