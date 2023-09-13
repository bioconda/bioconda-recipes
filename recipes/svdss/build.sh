#!/usr/bin/env bash

mkdir -p build
cd build
cmake -DCMAKE_BUILD_TYPE=Release -DCONDAPREFIX=${PREFIX} ..
make
cd ..

mkdir -p ${PREFIX}/bin
cp SVDSS ${PREFIX}/bin
