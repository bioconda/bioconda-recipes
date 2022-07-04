#!/bin/bash
make \
    CXX="${CXX}" \
    CXXFLAGS="${CXXFLAGS} -Wformat -O3" \
    LINKPATH="${LDFLAGS}"
install -d "${PREFIX}/bin"
install \
    *.pl \
    rascaf \
    rascaf-join \
    "${PREFIX}/bin/"
