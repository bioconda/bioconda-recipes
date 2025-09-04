#!/bin/bash

install -d "${PREFIX}/bin"

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"

make -j"${CPU_COUNT}"

install -v -m 0755 abawaca "${PREFIX}/bin"
