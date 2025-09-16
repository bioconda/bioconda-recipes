#!/bin/bash

export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
export CPATH=${PREFIX}/include

make
mkdir -p ${PREFIX}/bin
cp -f genion ${PREFIX}/bin
genion --help

