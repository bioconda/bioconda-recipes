#!/bin/bash
if [[ "$OSTYPE" == "darwin"* ]]; then
    make no_omp
else
    make
fi
mkdir -p "${PREFIX}/bin"
cp ./akt "${PREFIX}/bin"
