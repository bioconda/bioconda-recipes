#!/bin/bash
echo $PREFIX
ls $PREFIX/include
echo $PREFIX/include
ls $PREFIX/lib
echo $PREFIX/lib
ls $PREFIX/include/htslib
echo $PREFIX/include/htslib
mkdir build
cd build
cmake .. -DINSTALL_BIN_PREFIX=$PREFIX/bin -DINCLUDE_LIBRARY_PREFIX=$PREFIX/include -DLIBRARY_LINK_PREFIX=$PREFIX/lib
make
make install
mkdir -p $PREFIX/bin
cp bolt $PREFIX/bin