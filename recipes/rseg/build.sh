#!/bin/bash

if [[ ${target_platform} == "linux-aarch64" ]]; then
    make \
    CC="${CC} ${CFLAGS} ${CPPFLAGS} ${LDFLAGS} -DHIDE_INLINE_STATIC" \
    CXX="${CXX} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS} -Xlinker -zmuldefs"
    make install
    install -d "${PREFIX}/bin"
    install bin/* "${PREFIX}/bin/"
else
    make \
    CC="${CC} ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}" \
    CXX="${CXX} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS}"
    make install
    install -d "${PREFIX}/bin"
    install bin/* "${PREFIX}/bin/"
fi
