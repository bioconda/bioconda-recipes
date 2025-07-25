#!/bin/bash

make \
    CC="${CC} ${CFLAGS} ${CPPFLAGS} ${LDFLAGS} -DHIDE_INLINE_STATIC" \
    CXX="${CXX} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS} -Xlinker -zmuldefs"
make install
install -d "${PREFIX}/bin"
install bin/* "${PREFIX}/bin/"
