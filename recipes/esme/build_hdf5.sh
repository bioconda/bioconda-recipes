#!/bin/bash

set -ex

export CC=mpicc
export CXX=mpicxx
export FC=mpifort

# Bypass mpiexec dependency and runtime checks
export RUNPARALLEL=none
export cross_compiling=yes  # Skip runtime checks by enabling cross-compilation mode

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
