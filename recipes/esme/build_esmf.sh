#!/bin/bash

set -ex

if [[ "$mpi" == "openmpi" ]]; then
  export ESMF_COMM=openmpi
elif [[ "$mpi" == "psmpi" || "$mpi" == *"pich"* ]]; then
  export ESMF_COMM=mpich2
fi

export ESMF_INSTALL_PREFIX=${PREFIX}
export ESMF_INSTALL_BINDIR=${PREFIX}/bin
export ESMF_INSTALL_HEADERDIR=${PREFIX}/include
export ESMF_INSTALL_LIBDIR=${PREFIX}/lib

export ESMF_PIO="external"
export ESMF_PIO_INCLUDE=${PREFIX}/include
export ESMF_PIO_LIBPATH=${PREFIX}/lib

export ESMF_COMPILER=gfortran
export ESMF_CXXCOMPILER=mpicxx
export ESMF_DIR=$(pwd)/esme_esmf
export ESMF_NETCDF=nc-config
export ESMF_PNETCDF=pnetcdf-config
export ESMF_LAPACK_LIBS=-lopenblas \
export ESMF_LAPACK_LIBPATH="${PREFIX}"/lib
export ESMF_F90COMPILEOPTS="-fallow-argument-mismatch"

cd esme_esmf

make -j ${CPU_COUNT} lib

make install

export ESMFMKFILE=${PREFIX}/lib/libO/Linux.gfortran.64.${ESMF_COMM}.default/esmf.mk
