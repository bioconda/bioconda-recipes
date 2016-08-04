#!/bin/bash

mkdir -p $PREFIX/bin

./configure.py --shared --sub --no-pbbam HDF5_INCLUDE=$PREFIX/include HDF5_LIB=$PREFIX/lib

make configure-submodule

make build-submodule

make blasr

cp libcpp/alignment/libblasr.* $PREFIX/lib
cp libcpp/hdf/libpbihdf.* $PREFIX/lib
cp libcpp/pbdata/libpbdata.* $PREFIX/lib
LD_LIBRARY_PATH=$PREFIX/lib
