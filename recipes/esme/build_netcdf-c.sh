#!/bin/bash

set -ex

export CC=mpicc

cd esme_netcdf-c

./configure --prefix="${PREFIX}" \
            --disable-doxygen \
            --disable-doxygen-tasks \
            --disable-doxygen-build-release-docs \
            --disable-doxygen-pdf-output \
            --disable-dot \
            --disable-internal-docs \
            --enable-shared=yes \
	    --enable-static=no \
	    --enable-netcdf4 \
	    --enable-pnetcdf \
	    --disable-libxml2  # From Issue #2410: Skip DAP XML to avoid libncxml header failure

make -j ${CPU_COUNT}

make install
