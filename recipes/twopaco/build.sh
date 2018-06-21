#!/bin/bash

mkdir -p "$PREFIX/bin"

mkdir build
cd build
cmake  ../src
make VERBOSE=1
cp graphconstructor/twopaco $PREFIX/bin/
cp graphdump/graphdump $PREFIX/bin/
