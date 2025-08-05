#!/bin/bash

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -Wall -O3 -fPIC -DHIDE_INLINE_STATIC"
export CXXFLAGS="${CXXFLAGS} -Wall -O3 -fPIC -fmessage-length=50"
arch=$(uname -m)

install -d "${PREFIX}/bin"

if [[ "${arch}" == "aarch64" ]]; then
    export CPPFLAGS="${CPPFLAGS} -Xlinker -zmuldefs"
fi

make clean
make CC="${CC} -fcommon" \
    CXX="${CXX} -fcommon" \
    CCFLAGS="${CFLAGS} -L${PREFIX}/lib" \
    CXXFLAGS="${CXXFLAGS} -L${PREFIX}/lib" \
    OPTFLAGS="-O3" \
    -j1

make install
install -v -m 755 bin/* "${PREFIX}/bin"
