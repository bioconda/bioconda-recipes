#!/bin/bash

# Make m4 accessible to bison
# https://github.com/conda-forge/bison-feedstock/issues/7#issuecomment-431602144
export M4=m4
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export CPP_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include

./setup.py

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/bin/deps

cp scrapp.py ${PREFIX}/bin/
cp -r deps/ParGenes ${PREFIX}/bin/deps/
cp -r deps/mptp ${PREFIX}/bin/deps/
cp -r scripts ${PREFIX}/bin/