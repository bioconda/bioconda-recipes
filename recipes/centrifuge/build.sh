#!/bin/bash

set -xe

export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include

mkdir -p $PREFIX/bin

make -j ${CPU_COUNT} CXX=$CXX RELEASE_FLAGS="$CXXFLAGS"
make install prefix=$PREFIX

cp evaluation/{centrifuge_evaluate.py,centrifuge_simulate_reads.py} $PREFIX/bin
