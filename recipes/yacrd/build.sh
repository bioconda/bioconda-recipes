#!/bin/bash

mkdir -p $PREFIX/bin

mkdir build
cd build
cmake ..
make -j 8

cp yacrd $PREFIX/bin/

