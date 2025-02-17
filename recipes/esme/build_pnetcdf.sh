#!/bin/bash

set -ex

export CC=mpicc
export FC=mpifort

#---------------------------------------------------------------------
# Thread-safety feature, --enable-thread-safe, requires MPICH version
# 4.0.3 and later. The version of provided MPICH is 3.4.3.
# See bug fix in https://github.com/pmodels/mpich/pull/5954
#---------------------------------------------------------------------

THREAD_SAFE_FLAG=""
if [[ "$mpi" != *"mvapich"* ]]; then
  THREAD_SAFE_FLAG="--enable-thread-safe"
fi

export LDFLAGS="${LDFLAGS} -lpthread"

cd esme_pnetcdf

./configure --prefix="${PREFIX}" \
	    --with-mpi=${PREFIX} \
            --enable-shared=yes \
            --enable-static=no \
	    --disable-dependency-tracking \
            $THREAD_SAFE_FLAG

make -j ${CPU_COUNT}

make install
