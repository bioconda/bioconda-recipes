#!/bin/bash

make \
    CC="${CC} ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}" \
    CXX="${CXX} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS}"
make install
install -d "${PREFIX}/bin"
install bin/* "${PREFIX}/bin/"
