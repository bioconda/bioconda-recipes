#!/bin/bash

mkdir -p "${PREFIX}/bin"

export CFLAGS="${CFLAGS} -O3"
export CXXFLAGS="${CXXFLAGS} -O3"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -lz -lbz2 -llzma -L${PREFIX}/lib"

make CC="${CC}" CXX="${CXX}" HTSSRC="systemwide" -j"${CPU_COUNT}"
install -v -m 755 ./metaDMG-cpp ./misc/compressbam ./misc/extract_reads "${PREFIX}/bin"
