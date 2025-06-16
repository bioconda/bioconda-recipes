#!/bin/bash

set -ex

export CC=mpicc
export CXX=mpicxx
export CFLAGS=-O3

cd esme_omb

./configure --prefix=$PREFIX \
	    --disable-dependency-tracking \
            --enable-static=no

make -j"${CPU_COUNT}"

make install
