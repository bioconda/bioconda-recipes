#!/bin/bash

make \
    CXX="${CXX} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS} -std=c++11" \
    CC="${CC} ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}" \
    USER_WARNINGS='-Wno-strict-overflow'
 
mkdir -p "${PREFIX}/"{lib,include}
cp libStatGen*.a "${PREFIX}/lib/"
cp include/* "${PREFIX}/include/"
