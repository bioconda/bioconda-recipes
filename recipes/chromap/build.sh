#!/bin/bash

make \
    CXX="g++" \
    CXXFLAGS="${CXXFLAGS} -Wformat -O3" \
    LINKPATH="${LDFLAGS}"
install -d "${PREFIX}/bin"
install chromap \
    "${PREFIX}/bin/"
