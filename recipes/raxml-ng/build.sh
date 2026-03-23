#!/bin/bash

CMAKE_EXTRA_FLAGS="-DCMAKE_POLICY_VERSION_MINIMUM=3.5 -DUSE_VCF=ON -DUSE_TERRAPHAST=ON"

if [ "$(uname -m)" == "aarch64" ]
then
  # mannually disable x86 vector intrinsics on ARM
  CMAKE_EXTRA_FLAGS="${CMAKE_EXTRA_FLAGS} -DPORTABLE_BUILD=ON -DCORAX_ENABLE_SSE=OFF -DCORAX_ENABLE_AVX=OFF -DCORAX_ENABLE_AVX2=OFF"
fi

# pthreads
mkdir build_pthreads
pushd build_pthreads
   cmake ${CMAKE_EXTRA_FLAGS} ..
   make -j ${CPU_COUNT}
   install -d ${PREFIX}/bin
   install ../bin/raxml-ng ${PREFIX}/bin
popd

# mpi
if [ ! "$(uname)" = 'Darwin' ]
then
  mkdir build_mpi
  pushd build_mpi
     CXX=mpicxx cmake ${CMAKE_EXTRA_FLAGS} -DUSE_MPI=ON -DRAXML_BINARY_NAME=raxml-ng-mpi ..
     make -j ${CPU_COUNT}
     install -d ${PREFIX}/bin
     install ../bin/raxml-ng-mpi ${PREFIX}/bin
  popd
fi
