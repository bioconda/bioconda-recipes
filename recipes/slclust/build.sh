#!/bin/bash

set -xe

make -j ${CPU_COUNT} CC="${CXX} ${CXXFLAGS} -I${PWD}/include" install
cp bin/slclust $PREFIX/bin
