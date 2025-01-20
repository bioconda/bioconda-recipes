#!/bin/bash
set -e
set -x

mkdir -p ${PREFIX}/bin

mkdir build-conda
cd build-conda

echo "Current directory: ${PWD}"
ls -lh

cmake .. -DCONDA_BUILD=ON
make -j8
cd ..

echo "Current directory: ${PWD}"
ls -lh

cp ./bin/kmat_tools ${PREFIX}/bin
cp ./bin/muset ${PREFIX}/bin
cp ./bin/muset_pa ${PREFIX}/bin
