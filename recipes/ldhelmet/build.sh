#!/bin/bash
pushd LDhelmet_v1.10

make \
    CC="${CXX} ${CXXFLAGS} ${CPPFLAGS} -fcommon" \
    INC_FLAG="-I${PREFIX}/include" \
    LIB_FLAG="${LDFLAGS}"
install -d "${PREFIX}/bin"
install ldhelmet "${PREFIX}/bin/"
