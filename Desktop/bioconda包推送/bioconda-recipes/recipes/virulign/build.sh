#!/bin/bash

mkdir build
pushd build
cmake -DCMAKE_BUILD_TYPE=Release ..
make

mkdir -p $PREFIX/bin
cp ./src/virulign ${PREFIX}/bin/
