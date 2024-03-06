#!/bin/bash

pushd samtools
./configure \
    --prefix="${PREFIX}" \
    --with-htslib=system \
    CURSES_LIB='-ltinfow -lncursesw'
make lib
popd

pushd src
LIBS='-ldl -ldeflate' \
    make \
    CXX="${CXX} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS}"' -O3 -std=c++17 -DCNVNATOR_VERSION=\"$(VERSION)\" $(OMPFLAGS)' \
    SAMDIR=../samtools \
    SAMLIB='$(SAMDIR)/libbam.a -lhts' \
    HTSDIR="${PREFIX}/include" \
    ROOTSYS="${PREFIX}"

install -d "${PREFIX}/bin"
install cnvnator "${PREFIX}/bin/"
install -d "${SP_DIR}/pytools"
install pytools/* "${SP_DIR}/pytools"
install *.py *.pl "${PREFIX}/bin"
