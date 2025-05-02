#!/bin/bash

set -ex

export CC=mpicc
export FC=mpifort

cd esme_hdf5

./configure --prefix="${PREFIX}" \
            --with-zlib="${PREFIX}" \
            --with-szlib="${PREFIX}" \
            --enable-fortran \
	    --enable-parallel \
            --enable-threadsafe \
	    --enable-unsupported \
	    --enable-optimization=high \
            --enable-build-mode=production \
	    --disable-dependency-tracking \
            --enable-static=no \
	    --disable-doxygen-doc

make -j ${CPU_COUNT}

make install
