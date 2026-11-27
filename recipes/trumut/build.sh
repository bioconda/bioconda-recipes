#!/bin/bash
set -euo pipefail

make -j"${CPU_COUNT}" CXX="${CXX}" CXXFLAGS="${CXXFLAGS} -O3 -std=c++17 -D_LIBCPP_DISABLE_AVAILABILITY" LDFLAGS="${LDFLAGS}"
make install PREFIX="${PREFIX}"
