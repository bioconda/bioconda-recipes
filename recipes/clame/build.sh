#!/bin/bash
echo "SDSL compilation"
export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

echo "Binning compilation"
cd binning
make CPP=${CXX}
mkdir -p $PREFIX/bin
cp binning $PREFIX/bin
cd ..

