#!/bin/bash

export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

make
make -C consensus

cp calib $PREFIX/bin
cp consensus/calib_cons $PREFIX/bin
