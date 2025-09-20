#!/bin/bash

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3"

cmake -S . -B build -DCMAKE_INSTALL_PREFIX="${PREFIX}"

cmake --build build --target install -j "${CPU_COUNT}"
