#!/bin/bash
export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
make
cp mlRho $PREFIX/bin
chmod +x $PREFIX/bin/mlRho
