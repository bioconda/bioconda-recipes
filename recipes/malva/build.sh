#!/bin/bash

mkdir -p build

cd build
cmake -DCMAKE_BUILD_TYPE=Release ..
make

mkdir -p ${PREFIX}/bin
cp ../bin/malva-geno ${PREFIX}/bin
cp ../MALVA ${PREFIX}/bin
