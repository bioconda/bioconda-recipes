#!/bin/bash

cd src
make CXX=${CXX} CXXFLAGS="${CXXFLAGS}" LDFLAGS="${LDFLAGS}" CFLAGS="${CFLAGS}"
mkdir -p ${PREFIX}/bin
cp readItAndKeep ${PREFIX}/bin/
