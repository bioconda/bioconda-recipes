#!/bin/bash

# Avoid pedstats compile error (uses "char" instead of "unsigned char" leading to narrow reported).
export CXXFLAGS="${CXXFLAGS} -Wno-narrowing"
CFLAGS="-pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fPIC -fexceptions -fstack-protector --param=ssp-buffer-size=4 -O3" \
    make install INSTALLDIR="${PREFIX}/bin" \
    CXX="${CXX} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS}"

install -d "${PREFIX}/share/doc"
install -m644 LICENSE.twister README ChangeLog "${PREFIX}/share/doc/"
