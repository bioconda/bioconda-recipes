#!/bin/bash

# TODO: re-enable VCF support with -DUSE_VCF=ON in raxml-ng 2.0.1, after fixing htslib linking issue
CMAKE_EXTRA_FLAGS="-DCMAKE_POLICY_VERSION_MINIMUM=3.5 -DUSE_VCF=OFF -DUSE_TERRAPHAST=ON"

# manually disable x86 vector intrinsics on ARM (or any other non-x86 system)
if [ "$(uname -m)" != "x86_64" ]
then
  CMAKE_EXTRA_FLAGS="${CMAKE_EXTRA_FLAGS} -DPORTABLE_BUILD=ON -DCORAX_ENABLE_SSE=OFF -DCORAX_ENABLE_AVX=OFF -DCORAX_ENABLE_AVX2=OFF"
fi

if [ "$(uname -m)" == "aarch64" ]
then
  # on aarch64, build a portable binary using only armv8-a instructions
  CMAKE_EXTRA_FLAGS="${CMAKE_EXTRA_FLAGS} -DCORAX_BUILD_PORTABLE_ARCH=armv8-a"
elif [ "$(uname -m)" == "arm64" ] && [ "$(uname)" == "Darwin" ]
then
  # on osx-amd64, build a portable binary with NEON support
  CMAKE_EXTRA_FLAGS="${CMAKE_EXTRA_FLAGS} -DCORAX_BUILD_PORTABLE_ARCH=armv8-a+fp+simd"
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
