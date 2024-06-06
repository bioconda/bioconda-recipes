#!/bin/bash

set -xe

mkdir -p $PREFIX/bin

pushd vendor
    tar xf boost-1.55-bamrc.tar.gz
    patch -p0 < ${RECIPE_DIR}/boost-python3.patch
    tar czf boost-1.55-bamrc.tar.gz boost-1.55-bamrc
    rm -rf boost-1.55-bamrc
popd

mkdir build 
cd build
cmake ..

make
cp ./bin/bam-readcount ${PREFIX}/bin/