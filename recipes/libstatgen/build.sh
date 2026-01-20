#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3"
export CXXFLAGS="${CXXFLAGS} -O3"

mkdir -p "${PREFIX}/"{lib,include}

make CXX="${CXX} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS} -std=c++14" \
    CC="${CC} ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}" \
    USER_WARNINGS='-Wno-strict-overflow' \
    -j"${CPU_COUNT}"
 
cp libStatGen*.a "${PREFIX}/lib"
cp include/* "${PREFIX}/include"
