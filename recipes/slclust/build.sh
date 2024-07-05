#!/bin/bash

set -xe

make -j ${CPU_COUNT} CC="${CXX} ${CXXFLAGS} -I${PWD}/include" install
mkdir -p $PREFIX/bin
cp -f bin/slclust $PREFIX/bin
