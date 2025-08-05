#!/bin/bash

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3 -DHIDE_INLINE_STATIC"
export CXXFLAGS="${CXXFLAGS} -O3"
arch=$(uname -m)

install -d "${PREFIX}/bin"

if [[ ${target_platform} == "linux-aarch64" ]]; then
    export CPPFLAGS="${CPPFLAGS} -Xlinker -zmuldefs"
fi

make CC="${CC} -fcommon" \
    CXX="${CXX}" \
    CCFLAGS="${CFLAGS} ${CPPFLAGS} ${LDFLAGS}" \
    CXXFLAGS="${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS}" \
    -j"${CPU_COUNT}"

make install
install -v -m 755 bin/* "${PREFIX}/bin"
