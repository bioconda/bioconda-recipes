#!/bin/bash

mkdir -p $PREFIX/bin

export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
make
mv fermi2  $PREFIX/bin
mv fermi2.pl  $PREFIX/bin

