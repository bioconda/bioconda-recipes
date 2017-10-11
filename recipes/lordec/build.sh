#!/bin/bash

mkdir -p ${PREFIX}/bin

# create build directory
mkdir -p build
cd build

# compilation
cmake ..
make

# copy binaries
cp tools/lordec-* ${PREFIX}/bin
