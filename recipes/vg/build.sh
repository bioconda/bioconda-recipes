#!/bin/bash

export C_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

source source_me.sh
make static || (cat config.log ; exit 1)

mkdir -p $PREFIX/bin
cp bin/vg $PREFIX/bin
