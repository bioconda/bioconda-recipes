#!/bin/bash

set -ex

# Set cache variables to bypass MPI runtime tests
export ac_cv_lib_mpi_MPI_File_open=yes
export hdf5_cv_mpi_io=yes
export hdf5_cv_mpi_special_collective_io_works=yes
export hdf5_cv_mpi_complex_derived_datatype_works=yes

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
