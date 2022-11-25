#!/bin/bash

mkdir -p ${PREFIX}/bin
make CC=${CXX} CFLAGS="${CXXFLAGS}"
