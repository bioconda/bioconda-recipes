#!/bin/bash

make \
    CXX="${CXX} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS}" \
    CC="${CC} ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}" \
    AR="${AR} cr"
install -d "${PREFIX}/bin"
install ./bin/* "${PREFIX}/bin/"
