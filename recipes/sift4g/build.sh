#!/bin/bash

make -j 2 \
    CC="${CC} ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}" \
    CP="${CXX} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS}"

install -d "${PREFIX}/bin"
install bin/* "${PREFIX}/bin/"
