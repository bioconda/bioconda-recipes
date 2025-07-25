#!/bin/bash
arch=$(uname -m)
if [[ ${target_platform} == "linux-aarch64" ]]; then
    CFLAGS="${CPPFLAGS} -DHIDE_INLINE_STATIC"
    CPPFLAGS="${CPPFLAGS} -Xlinker -zmuldefs"
fi
    make \
    CC="${CC} ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}" \
    CXX="${CXX} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS}"
    make install
    install -d "${PREFIX}/bin"
    install bin/* "${PREFIX}/bin/"
