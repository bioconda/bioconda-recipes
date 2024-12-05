#!/bin/bash

set -xe 

make -j ${CPU_COUNT} CXXFLAGS="${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS}"
install -d "${PREFIX}/bin"
install bin/filtlong "${PREFIX}/bin/"
