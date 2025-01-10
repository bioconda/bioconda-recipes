#!/usr/bin/env bash

set -x

export CFLAGS="${CFLAGS} -idirafter ${PREFIX}/include" 
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export LINKFLAGS="-L${PREFIX}/lib"
export EIGEN_CFLAGS="-idirafter ${PREFIX}/include/eigen3"

mkdir -p "${PREFIX}"/{bin,lib,share}

ln -s ${CC} ${CONDA_PREFIX}/bin/gcc
ln -s ${CXX} ${CONDA_PREFIX}/bin/g++

ARCH=native CFLAGS="${CXXFLAGS}" ./configure -conda || (cat configure.log && exit 123)

./build 

# debug
ls -la bin/

cp -r bin lib share "${PREFIX}"

unlink ${CONDA_PREFIX}/bin/g++
unlink ${CONDA_PREFIX}/bin/gcc
