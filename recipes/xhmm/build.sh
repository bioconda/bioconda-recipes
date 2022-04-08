#!/bin/bash

make \
    GCC="${CC} ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}" \
    CXX="${CXX} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS} -std=c++03"
install -d "${PREFIX}/bin"
install build/execs/xhmm "${PREFIX}/bin/"
