#!/bin/bash

install -d "${PREFIX}/bin"
make \
    CC="${CC} ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}" \
    CXX="${CXX} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS}" \
    PREFIX="${PREFIX}/bin" \
    PKG_VERSION="${PKG_VERSION}" \
    -j"${CPU_COUNT}" \
    clean all install
