#!/bin/bash
CXXFLAGS="${CXXFLAGS} -std=c++03" \
    make CXX="${CXX}"
install -d "${PREFIX}/bin"
install snap-aligner "${PREFIX}/bin/"
