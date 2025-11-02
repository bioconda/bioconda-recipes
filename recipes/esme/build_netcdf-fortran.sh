#!/bin/bash

set -ex

# CUDA stubs only for MVAPICH (resolves libmpi.so deps in ESMF linking)
if [[ "${mpi}" == mvapich* ]]; then
  source ${RECIPE_DIR}/mvapich_cuda_stub.sh
fi

unset CC CXX FC F77 F90 F95 CFLAGS CXXFLAGS FCFLAGS FFLAGS LDFLAGS CPPFLAGS

export CC=mpicc
export FC=mpifort

export CPPFLAGS="-I${PREFIX}/include"
export LDFLAGS="-L${PREFIX}/lib"

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
