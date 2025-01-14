#!/bin/bash

set -ex

export CC=mpicc
export FC=mpifort

cd esme_pnetcdf

./configure --prefix="${PREFIX}" \
	    --with-mpi=${PREFIX} \
            --enable-shared=yes \
            --enable-static=no \
	    --disable-dependency-tracking \
            --enable-thread-safe

make -j ${CPU_COUNT}

make install
