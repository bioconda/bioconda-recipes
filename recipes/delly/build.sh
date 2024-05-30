#!/bin/sh

mkdir -p "${PREFIX}/bin"
make all CXX=$CXX CXXFLAGS="-I${PREFIX}/include -L${PREFIX}/lib"
cp src/delly "${PREFIX}/bin"
