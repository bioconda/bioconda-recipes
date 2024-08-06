#!/bin/bash

set -xe

./configure --prefix=$PREFIX
make -j ${CPU_COUNT} CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" install
cp $PREFIX/bin/ParaFly $PREFIX
