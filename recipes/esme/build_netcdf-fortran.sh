#!/bin/bash

set -ex

# CUDA stubs only for MVAPICH (resolves libmpi.so deps in ESMF linking)
if [[ "${mpi}" == mvapich* ]]; then
  source ${RECIPE_DIR}/mvapich_cuda_stub.sh
fi

CONDA_LDFLAGS="${LDFLAGS}"

export CC=mpicc
export FC=mpifort

cd esme_netcdf-fortran

export HDF5_PLUGIN_PATH="${PREFIX}/lib/hdf5/plugin"

export LDFLAGS="${CONDA_LDFLAGS}"

./configure --prefix="${PREFIX}" \
            --disable-doxygen \
            --disable-dot \
            --disable-internal-docs \
            --enable-static=no \
            --enable-shared=yes

make -j ${CPU_COUNT}

make install
