#!/bin/bash

set -ex

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
