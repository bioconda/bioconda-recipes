#!/bin/bash
ldconfig -p | grep htslib
ldconfig -p | grep tbb
mkdir build
cd build
cmake .. -DINSTALL_PREFIX=$(pwd) -DINCLUDE_LIBRARY_PREFIX=${PREFIX}/include -DLIBRARY_LINK_PREFIX=${PREFIX}/lib
make
make install
mkdir -p $PREFIX/bin
cp bolt $PREFIX/bin