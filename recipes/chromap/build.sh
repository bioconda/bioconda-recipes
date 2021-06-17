#!/bin/bash

install -d objs
make \
    CXX="${CXX}" \
    CXXFLAGS="${CXXFLAGS} -Wformat -O3" \
    LINKPATH="${LDFLAGS}"
install -d "${PREFIX}/bin"
install chromap \
    "${PREFIX}/bin/"
