#!/bin/sh

cd FamSeq || true
cd src
make \
    CC="${CXX} ${CXXFLAGS} ${CPPFLAGS}" \
    LDFLAGS="${LDFLAGS}"
install -d "${PREFIX}/bin"
install FamSeq "${PREFIX}/bin/"
