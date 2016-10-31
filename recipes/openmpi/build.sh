#!/bin/bash

##This is the recipe from mpi4py/openmpi

export CC=${CC-cc}
export CXX=${CXX-c++}
./configure \
  --disable-mpi-fortran \
  --disable-dependency-tracking \
  --prefix=$PREFIX
make -j $CPU_COUNT
make install
