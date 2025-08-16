#!/bin/bash
set -ex

export CC=mpicc
export FC=mpifort
export MPICC=mpicc
export MPIFC=mpifort
export CPPFLAGS="-I${CONDA_PREFIX}/include"
export FCFLAGS="-fPIC -fallow-argument-mismatch -I${CONDA_PREFIX}/include"
export FFLAGS="-fPIC -fallow-argument-mismatch -I${CONDA_PREFIX}/include"
export RUNSERIAL="prterun -n 1"
export RUNPARALLEL="prterun -n ${NPROCS:=${CPU_COUNT}}"

cd esme_hdf5

# Configure
./configure --prefix="${PREFIX}" \
            --with-zlib="${PREFIX}" \
            --with-szlib="${PREFIX}" \
            --enable-parallel \
            --enable-fortran \
            --enable-threadsafe \
            --enable-unsupported \
            --enable-optimization=high \
            --enable-build-mode=production \
            --disable-dependency-tracking \
            --enable-static=no \
            --disable-doxygen-doc

make -j ${CPU_COUNT}
make install
