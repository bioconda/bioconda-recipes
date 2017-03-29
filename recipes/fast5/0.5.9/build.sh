#!/bin/bash
export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include

mkdir -p $PREFIX/include/fast5

cp src/fast5.hpp $PREFIX/include/fast5/
cp src/hdf5_tools.hpp $PREFIX/include/fast5/



