#!/bin/bash
set -x

tar -xzf mrbayes-3.2.6.tar.gz
cd mrbayes-3.2.6/src
autoconf

# build version with MPI & Beagle
./configure \
    --prefix=$PREFIX \
    --disable-debug \
    --with-beagle=$PREFIX \
    --enable-mpi

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
