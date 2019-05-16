#!/bin/bash

export LIBRARY_PATH=${PREFIX}/lib

make
mkdir -p $PREFIX/bin
cp build/execs/xhmm $PREFIX/bin
