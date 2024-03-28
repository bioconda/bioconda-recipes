#!/bin/bash
sed -i 's/\-mpopcnt//g' Makefile

make \
    CC="${CC} ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}" \
    CXX="${CXX} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS}"
install -d "${PREFIX}/bin"
install ./akt "${PREFIX}/bin/"
