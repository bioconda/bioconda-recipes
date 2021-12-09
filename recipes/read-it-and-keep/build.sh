#!/bin/bash

cd src
make CXX=${CXX} CXXFLAGS="${CXXFLAGS}" LDFLAGS="${LDFLAGS}"
mkdir -p ${PREFIX}/bin
cp readItAndKeep ${PREFIX}/bin/
