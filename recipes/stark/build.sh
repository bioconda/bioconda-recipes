#!/bin/bash

mkdir -p build
cd build

cmake ..
make

mkdir -p $PREFIX/bin
cp stark $PREFIX/bin
