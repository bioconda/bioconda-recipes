#!/bin/bash
set -ex

export CC=mpicc
export CXX=mpicxx
export FC=mpifort
export RUNSERIAL="prterun -n 1"
export RUNPARALLEL="prterun -n \$\${NPROCS:=6}"

cd esme_hdf5

# Patch configure to skip the failing Fortran MPI-IO test
sed -i 's/configure: error: unable to link a simple MPI-IO Fortran program/echo "Skipping Fortran MPI-IO test for PsMPI"/g' configure

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
