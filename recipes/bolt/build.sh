#!/bin/bash
cd ${PREFIX}/include && ls
cd ${PREFIX}/lib && ls
cd ${PREFIX}/include/htslib && ls
mkdir build
cd build
cmake .. -DINSTALL_BIN_PREFIX=$(pwd) -DINCLUDE_LIBRARY_PREFIX=${PREFIX}/include -DLIBRARY_LINK_PREFIX=${PREFIX}/lib
make
make install
mkdir -p $PREFIX/bin
cp bolt $PREFIX/bin