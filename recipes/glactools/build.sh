#!/bin/bash

make CC="${CC}  -fcommon ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}" CXX="${CXX} -fcommon ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS}"
make install INSTALLDIR="${PREFIX}/bin/"

