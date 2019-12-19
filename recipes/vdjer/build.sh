#!/bin/bash

mkdir -p $PREFIX/bin
export LIBRARY_PATH=${PREFIX}/lib
export C_INCLUDE_PATH=${PREFIX}/include
make
cp -f vdjer $PREFIX/bin/vdjer
chmod +x $PREFIX/bin/vdjer
