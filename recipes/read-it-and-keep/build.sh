#!/bin/bash

cd src
make CXX=${CXX} CXXFLAGS="${CXXFLAGS}" LDFLAGS="${LDFLAGS}" CFLAGS="${CFLAGS} -L${PREFIX}/lib"
mkdir -p ${PREFIX}/bin
cp readItAndKeep ${PREFIX}/bin/
