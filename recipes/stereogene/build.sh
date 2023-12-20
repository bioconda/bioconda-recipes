#!/bin/bash

cd src
mv Smoother.cpp smoother.cpp
mv Binning.cpp binning.cpp
make \
    CC="${CC} ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}" \
    CPP="${CXX} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS} -std=gnu++11"

install -d "${PREFIX}/bin"
install \
    StereoGene \
    Binner \
    Confounder \
    ParseGenes \
    Projector \
    Smoother \
    "${PREFIX}/bin/"
