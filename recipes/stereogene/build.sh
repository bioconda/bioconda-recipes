#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3"
export CXXFLAGS="${CXXFLAGS} -O3"

mkdir -p "${PREFIX}/bin"

cd src

mv Smoother.cpp smoother.cpp
mv Binning.cpp binning.cpp

make CC="${CC} ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}" \
    CPP="${CXX} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS} -std=gnu++11" \
    -j"${CPU_COUNT}"

install -d "${PREFIX}/bin"
install -v -m 0755 \
    StereoGene \
    Binner \
    Confounder \
    ParseGenes \
    Projector \
    Smoother \
    "${PREFIX}/bin"
