#!/bin/bash

make \
    CC="${CC} ${CPPFLAGS} ${CFLAGS} ${LDFLAGS}" \
    CXX="${CXX} ${CPPFLAGS} ${CXXFLAGS} ${LDFLAGS}"

mkdir -p "${PREFIX}/bin"
chmod +x *.py *.sh bsmap
cp *.py *.sh bsmap "${PREFIX}/bin/"

