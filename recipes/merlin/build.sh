#!/bin/bash

make \
    CXX="${CXX}" \
    CFLAGS="${CXXFLAGS} -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fPIC -fexceptions -fstack-protector --param=ssp-buffer-size=4 -O3"
mkdir -p "${PREFIX}/bin" "${PREFIX}/share/doc"
make install INSTALLDIR="${PREFIX}/bin"
install -m644 LICENSE.twister README ChangeLog "${PREFIX}/share/doc/"
