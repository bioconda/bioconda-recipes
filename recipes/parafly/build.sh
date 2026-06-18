#!/bin/bash

set -xe

./configure --prefix=$PREFIX
make -j ${CPU_COUNT} CXX="${CXX}" CXXFLAGS="${CXXFLAGS} -pedantic -fopenmp -Wall -Wextra -Wno-long-long -Wno-deprecated" install
cp $PREFIX/bin/ParaFly $PREFIX
