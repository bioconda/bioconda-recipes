#!/bin/bash

mkdir -p ${PREFIX}/bin/

mkdir -p bin/
C_OPTS="${CPPFLAGS} ${CXXFLAGS}" make CC=$CXX GSL_PATH="${PREFIX}/"
make install BIN_INSTALL=${PREFIX}/bin/
mv ${PREFIX}/bin/nemoage* ${PREFIX}/bin/nemoage
