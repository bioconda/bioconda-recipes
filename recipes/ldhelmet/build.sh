#!/bin/bash

make \
    CC="${CXX} ${CXXFLAGS} ${CPPFLAGS}" \
    INC_FLAG="-I${PREFIX}/include" \
    LIB_FLAG="${LDFLAGS}"
install -d "${PREFIX}/bin"
install ldhelmet "${PREFIX}/bin/"
