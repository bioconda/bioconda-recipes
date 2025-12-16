#!/bin/bash

set -xe

# use newer config.guess and config.sub that support osx-arm64
cp -f ${RECIPE_DIR}/config.* ./am-aux/

# build version with MPI & Beagle
./configure \
    --prefix=$PREFIX \
    --disable-debug \
    --with-beagle=$PREFIX \
    --with-mpi

make -j$CPU_COUNT
make install
make clean
mv $PREFIX/bin/mb{,-mpi}


# build version with Beagle only
./configure \
    --prefix=$PREFIX \
    --disable-debug \
    --with-beagle=$PREFIX

make -j$CPU_COUNT
make install
