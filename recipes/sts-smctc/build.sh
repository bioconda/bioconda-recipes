#!/bin/bash

make \
    CXX="${CXX}" \
    CXXFLAGS="${CXXFLAGS} -O3 -std=c++11 -I ../include" \
    libraries

mkdir -p "${PREFIX}/"{lib,include}
cp lib/libsmctc.a "${PREFIX}/lib/"
cp include/*.hh "${PREFIX}/include/"
