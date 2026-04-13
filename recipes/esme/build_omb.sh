#!/bin/bash

set -ex

export CC=mpicc
export CXX=mpicxx
export CFLAGS=-O3

cd "${SRC_DIR}/esme_omb"

./autogen.sh

./configure --prefix=$PREFIX \
	    --disable-dependency-tracking \
            --enable-static=no

make -j"${CPU_COUNT}"

make install
