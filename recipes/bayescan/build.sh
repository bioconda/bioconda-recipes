#!/bin/bash

cd source
make CXXFLAGS="${CXXFLAGS} -std=c++14"
mkdir -p "${PREFIX}/bin"
cp bayescan2 "${PREFIX}/bin/"
