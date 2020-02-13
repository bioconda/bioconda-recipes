#!/bin/bash
mkdir -p build
cd build
cmake ../ -DCMAKE_INSTALL_PREFIX=$PREFIX -DBOOST_INCLUDEDIR=$PREFIX/include/boost -DBOOST_LIBRARYDIR=$PREFIX/lib
make
rm -f lib/libhts*so
make install
