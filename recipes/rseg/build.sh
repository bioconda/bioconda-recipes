#!/bin/bash
arch=$(uname -m)
CFLAGS="${CPPFLAGS} -DHIDE_INLINE_STATIC"
if [[ ${target_platform} == "linux-aarch64" ]]; then
    CPPFLAGS="${CPPFLAGS} -Xlinker -zmuldefs"
fi
    make \
    CC="${CC} ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}" \
    CXX="${CXX} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS}"
    make install
    install -d "${PREFIX}/bin"
    install bin/* "${PREFIX}/bin/"
