#!/bin/bash

mkdir -p $PREFIX/bin

#wget -O libcpp.tar.gz https://github.com/PacificBiosciences/blasr_libcpp/archive/0ae16915b48d1ee77cb7cd4c95764181467c7175.tar.gz
#tar -xvf libcpp.tar.gz
#mv blasr_libcpp-0ae16915b48d1ee77cb7cd4c95764181467c7175 libcpp

export HDF5_INCLUDE=$PREFIX/include 
export HDF5_LIB=$PREFIX/lib
./configure.py --shared --sub --no-pbbam 

make configure-submodule

make build-submodule

make blasr
cp blasr $PREFIX/bin
cp libcpp/alignment/libblasr.* $PREFIX/lib
cp libcpp/hdf/libpbihdf.* $PREFIX/lib
cp libcpp/pbdata/libpbdata.* $PREFIX/lib
export LD_LIBRARY_PATH=$PREFIX/lib
