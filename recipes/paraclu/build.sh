#!/bin/bash

make CXX="${CXX}" CXXFLAGS="${CXXFLAGS}"

mkdir -p "${PREFIX}/bin"
cp paraclu "${PREFIX}/bin/"
cp paraclu-cut.sh "${PREFIX}/bin/paraclu-cut"
