#!/bin/bash

set -ex

# CUDA stubs only for MVAPICH (resolves libmpi.so deps in ESMF linking)
if [[ "${mpi}" == mvapich* ]]; then
  source ${RECIPE_DIR}/mvapich_cuda_stub.sh
fi

export ESMF_F90=mpif90
export ESMF_CXX=mpicxx
export ESMF_C=mpicc

export ESMF_CPP="${CPP} -E -P -x c"

if [[ "$mpi" == "openmpi" ]]; then
  export ESMF_COMM=openmpi
elif [[ "$mpi" == "psmpi" || "$mpi" == *"pich"* ]]; then
  export ESMF_COMM=mpich
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
export ESMF_CXXCOMPILEOPTS="$ESMF_CXXCOMPILEOPTS -include cstdint"

cd esme_esmf

make -j ${CPU_COUNT}

make install

echo "_________________________________________________________"

find ${PREFIX} -name esmf.mk

echo "_________________________________________________________"

export ESMFMKFILE=${PREFIX}/lib/esmf.mk
