#!/bin/bash

set -x

if [[ ${target_platform} =~ linux.* ]]; then
    make -C general  CC="${CC}" CXX="${CXX}" DEBUG="${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS} -std=c++03"
    make -C bmtagger CC="${CC}" CXX="${CXX}" DEBUG="${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS} -std=c++03"
    cd bmtagger
fi

install -d "${PREFIX}/bin"
install bmfilter "${PREFIX}/bin/"
