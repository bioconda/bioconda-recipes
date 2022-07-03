#!/bin/sh

make CC="${CXX}" LINK="${CXX}" SWITCHES="${CPPFLAGS} ${CXXFLAGS} -std=c++14 ${LDFLAGS}"
install -d "${PREFIX}/bin"
install bin/rapidnj "${PREFIX}/bin/"
