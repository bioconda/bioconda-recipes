#!/bin/bash

# make \
#     CC="${CC}" \
#     CXX="${CXX}" \
#     CFLAGS="${CFLAGS}" \
#     CXXFLAGS="${CXXFLAGS}" \
#     LDFLAGS="${LDFLAGS}" \
#     prefix="${PREFIX}"
mkdir -p ${PREFIX}/bin
cmake -S . -B build
cmake --build build
#mkdir -p ${PREFIX}/bin
cp build/mupbwt ${PREFIX}/bin

