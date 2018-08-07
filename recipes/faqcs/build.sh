#!/bin/bash

export CPLUS_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

make
mkdir -p $PREFIX/bin
cp FaQCs $PREFIX/bin
