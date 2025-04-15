#!/bin/bash

export CC=$(basename ${C_COMPILER})
export CXX=$(basename ${CXX_COMPILER})
gcc --version
cd FM/
make
cd ../semiWFA/
make
cd ../
make
mkdir -p $PREFIX/bin
cp panaln $PREFIX/bin

