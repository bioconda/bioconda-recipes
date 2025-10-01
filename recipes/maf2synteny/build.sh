#!/bin/bash

make CXX="${CXX}" CXXFLAGS="${CXXFLAGS} -O3" -j"${CPU_COUNT}"

install -d "${PREFIX}/bin"
install -v -m 0755 maf2synteny "${PREFIX}/bin"
