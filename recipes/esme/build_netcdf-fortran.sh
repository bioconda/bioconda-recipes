#!/bin/bash

set -ex

unset CC CXX FC F77 F90 F95 CFLAGS CXXFLAGS FCFLAGS FFLAGS LDFLAGS CPPFLAGS

export CC=mpicc
export FC=mpifort

cd esme_netcdf-fortran

export HDF5_PLUGIN_PATH="${PREFIX}/lib/hdf5/plugin"

./configure --prefix="${PREFIX}" \
            --disable-doxygen \
            --disable-dot \
            --disable-internal-docs \
            --enable-static=no \
            --enable-shared=yes

make -j ${CPU_COUNT}

make install
