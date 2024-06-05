#!/bin/bash

set -xe

mkdir -p $PREFIX/bin

mkdir build 
cd build
cmake ..
make
cp ./bin/bam-readcount ${PREFIX}/bin/