#!/bin/bash
export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

if [[ "$OSTYPE" == "darwin"* ]]; then
    make no_omp
else
    make
fi
mkdir -p "${PREFIX}/bin"
cp ./akt "${PREFIX}/bin"
