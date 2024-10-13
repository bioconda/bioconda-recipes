#!/bin/bash

set -xe

if [[ ${target_platform} =~ linux.* ]] ; then
    make -j ${CPU_COUNT} -C general \
        CC="${CC} ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}" \
        CXX="${CXX} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS}"
    make -j ${CPU_COUNT} -C bmtagger \
        CC="${CC} ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}" \
        CXX="${CXX} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS}"
    cd bmtagger
fi

install -d "${PREFIX}/bin"
install bmtool "${PREFIX}/bin/"
