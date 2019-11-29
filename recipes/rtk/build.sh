#!/bin/bash

# https://bioconda.github.io/troubleshooting.html#zlib-errors
export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include


echo "Compiling RTK"
cd rtk && make
echo "Moving binary"
mkdir -p ${PREFIX}/bin
mv rtk ${PREFIX}/bin/
