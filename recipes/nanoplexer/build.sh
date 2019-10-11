#!/bin/bash

export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

mkdir -p $PREFIX/bin
make
cp ./bin/nanoplexer $PREFIX/bin/nanoplexer

