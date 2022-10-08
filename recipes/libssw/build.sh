#!/bin/bash

export JAVA_HOME="${PREFIX}"

cd src
make \
    CC="${CC}" CXX="${CXX}" \
    CFLAGS="${CFLAGS} ${LDFLAGS}" \
    CXXFLAGS="${CXXFLAGS} ${LDFLAGS}"
make java \
    CC="${CC}" CXX="${CXX}" \
    CFLAGS="${CFLAGS} ${LDFLAGS}" \
    CXXFLAGS="${CXXFLAGS} ${LDFLAGS}"

install -d "${PREFIX}/bin"
install \
    example_cpp \
    *.py* \
    ssw_test \
    ssw.jar \
    "${PREFIX}/bin/"

mkdir -p "${PREFIX}/"{lib,include}
cp *.so "${PREFIX}/lib"
cp *.h "${PREFIX}/include"
cp ssw.c "${PREFIX}/include"
cp ssw_cpp.cpp "${PREFIX}/include"
