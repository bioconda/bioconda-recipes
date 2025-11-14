#!/bin/bash

set -ex

export CC=mpicc
export FC=mpifort

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
