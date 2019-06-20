#!/bin/bash

cd src
export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
make
mkdir -p $PREFIX/bin
cp minion reaper swan tally $PREFIX/bin
