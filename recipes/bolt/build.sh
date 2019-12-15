#!/bin/bash
mkdir build
cd build
cmake .. -DINSTALL_BIN_PREFIX=$(pwd) -DINCLUDE_LIBRARY_PREFIX=/usr/local/include -DLIBRARY_LINK_PREFIX=/usr/local/lib/
make
make install
mkdir -p $PREFIX/bin
cp bolt $PREFIX/bin