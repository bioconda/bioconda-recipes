#!/bin/bash

make -j CXXFLAGS="${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS}"
install -d "${PREFIX}/bin"
install bin/filtlong "${PREFIX}/bin/"
