#!/bin/bash
starcode=$PREFIX/opt/$PKG_NAME-$PKG_VERSION
#export C_INCLUDE_PATH=${PREFIX}/include
#export LIBRARY_PATH=${PREFIX}/lib

make
mkdir -p $PREFIX/bin
cp starcode $PREFIX/bin