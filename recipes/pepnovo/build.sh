#!/bin/bash

mkdir -p ${PREFIX}/bin
cd src/
make CC="${CXX}" CFLAGS="${CXXFLAGS}" LDFLAGS="${LDFLAGS}"
cp PepNovo_bin ${PREFIX}/bin/pepnovo
