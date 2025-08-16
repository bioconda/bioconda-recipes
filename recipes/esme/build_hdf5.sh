#!/bin/bash
set -ex

# Set MPI environment variables for PsMPI
export MPICC=mpicc
export MPICXX=mpicxx
export MPIFC=mpifort
export MPIF77=mpifort
export MPIF90=mpifort

# Ensure MPI libraries are found
export MPI_C_COMPILER=mpicc
export MPI_CXX_COMPILER=mpicxx
export MPI_Fortran_COMPILER=mpifort

# Set compiler flags to ensure proper linking including Fortran MPI libraries
export CFLAGS="-fPIC $CFLAGS"
export CXXFLAGS="-fPIC $CXXFLAGS"
export FCFLAGS="-fPIC $FCFLAGS"
export FFLAGS="-fPIC $FFLAGS"

# Add explicit Fortran MPI library linking
export LIBS="-lmpifort $LIBS"

# CRITICAL: Override conda's compiler settings with MPI wrappers
export CC=mpicc
export CXX=mpicxx
export FC=mpifort

export RUNSERIAL="prterun -n 1"
export RUNPARALLEL="prterun -n \$\${NPROCS:=6}"

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
