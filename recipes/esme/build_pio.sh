#!/bin/bash

set -ex

export CC=mpicc
export FC=mpifort

cd esme_pio

autoreconf -i

./configure --prefix="${PREFIX}" \
            --enable-fortran \
            --enable-netcdf-integration \
	    --disable-docs \
            --disable-developer-docs \
            CFLAGS="-O2 -DENABLE_THREAD_SAFE" \
            FCFLAGS="-O2"

make -j ${CPU_COUNT}
	   
make install
