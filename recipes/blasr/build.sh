#!/bin/bash

mkdir -p $PREFIX/bin

export HDF5_INCLUDE=$PREFIX/include
export HDF5_LIB=$PREFIX/lib

./configure.py --shared --sub --no-pbbam
make configure-submodule

make build-submodule
make blasr
cp blasr $PREFIX/bin

