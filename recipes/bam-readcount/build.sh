#!/bin/bash

set -xe

mkdir -p $PREFIX/bin

mkdir build 
cd build
cmake ..
make -j ${CPU_COUNT}
cp ./bin/bam-readcount ${PREFIX}/bin/