#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"

install -d "${PREFIX}/bin"

make -j"${CPU_COUNT}"

install -v -m 0755 abundancebin "${PREFIX}/bin"
