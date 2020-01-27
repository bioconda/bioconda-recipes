#!/bin/bash

mkdir -p $PREFIX/bin
mkdir build
cd build
cmake ..
make
cp spring $PREFIX/bin
