#!/usr/bin/env bash

make \
    CXX="${CXX} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS}" \
    CC="${CC} ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}"

install -d "${PREFIX}/bin"
install alder "${PREFIX}/bin/"
