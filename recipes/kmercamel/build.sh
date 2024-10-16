#!/bin/bash

set -xe

make -j ${CPU_COUNT} CXX="${CXX} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS}"
install -d "${PREFIX}/bin"
install kmercamel "${PREFIX}/bin/"
