#!/bin/bash

set -xe

CXXFLAGS="${CXXFLAGS} -std=c++03" \
    make CXX="${CXX}" -j ${CPU_COUNT}
install -d "${PREFIX}/bin"
install snap-aligner "${PREFIX}/bin/"
