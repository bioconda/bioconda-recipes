#!/bin/bash

set -ex

export CC=mpicc
export FC=mpifort

cd "${SRC_DIR}/esme_netcdf-c"

autoreconf -fiv

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
	    --disable-filters \
	    --disable-libxml2

make -j ${CPU_COUNT}

make install
