#!/bin/bash
make vargeno \
    CC="${CXX} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS}" \
    CXX="${CXX} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS}"
install -d "${PREFIX}/bin"
install vargeno "${PREFIX}/bin/"
