#!/bin/bash

if [[ ${target_platform} =~ linux.* ]] ; then
    make -C general \
        CC="${CC} ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}" \
        CXX="${CXX} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS}"
    make -C bmtagger \
        CC="${CC} ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}" \
        CXX="${CXX} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS}"
    cd bmtagger
fi

install -d "${PREFIX}/bin"
install bmtool "${PREFIX}/bin/"
