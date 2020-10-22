#!/bin/bash

make CC="${CXX} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS}"
install -d "${PREFIX}/bin"
install \
    fmlrc \
    fmlrc-convert \
    "${PREFIX}/bin/"
