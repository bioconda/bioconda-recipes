#!/bin/bash
set -euo pipefail

make -j"${CPU_COUNT}" CXX="${CXX}" CXXFLAGS="${CXXFLAGS} -O3 -std=c++17" LDFLAGS="${LDFLAGS}"
make install PREFIX="${PREFIX}"
