#!/bin/bash

mkdir -p "${PREFIX}/bin"

export CFLAGS="${CFLAGS} -O3"
export CXXFLAGS="${CXXFLAGS} -O3"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

make clean

make CC="${CC}" CXX="${CXX}" HTSSRC="systemwide" -j"${CPU_COUNT}"

install -v -m 755 ./metaDMG-cpp ./misc/compressbam "${PREFIX}/bin"
