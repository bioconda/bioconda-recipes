#!/usr/bin/env bash

# cmake configuration for pinned version of gromacs has aberrant static library
# listed where only shared objects are actually installed. this creates an impossible
# to resolve dependency in the cmake-derived makefile. as this is an old gromacs
# version, and updating gromacs version for this package requires substantial interface
# changes, instead just ad hoc edit the target.
find ${PREFIX}/share/cmake/gromacs -type f -name "*" -exec sed -i 's/libfftw3f.a/libfftw3f.so/' {} \;

mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} ..
make
mkdir -p ${PREFIX}/bin
cp chap ${PREFIX}/bin
