#!/usr/bin/env bash

set -x

export RPATH="${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -idirafter ${PREFIX}/include" 
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib -lxcb"
export LINKFLAGS="-L${PREFIX}/lib -lxcb"
export LINKLIB_FLAGS="${LINKFLAGS}"
export EIGEN_CFLAGS="-idirafter ${PREFIX}/include/eigen3"

mkdir -p "${PREFIX}"/{bin,lib,share}

ln -s ${CC} ${CONDA_PREFIX}/bin/gcc
ln -s ${CXX} ${CONDA_PREFIX}/bin/g++

# debug
find ${CONDA_PREFIX} -name "*libxcb*.*"

ARCH=native CFLAGS="${CXXFLAGS}" ./configure -conda -openmp || (cat configure.log && exit 123)

./build 

# debug
ls -la bin/

cp -r bin lib share "${PREFIX}"

unlink ${CONDA_PREFIX}/bin/g++
unlink ${CONDA_PREFIX}/bin/gcc
