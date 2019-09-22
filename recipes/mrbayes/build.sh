#!/bin/bash
set -x

# build version with MPI & Beagle
LD_LIBRARY_PATH=${PREFIX}/lib  # this gets the wrong ncurses otherwise
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
