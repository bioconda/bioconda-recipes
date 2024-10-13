#!/bin/bash
export CXXFLAGS=${CXXFLAGS} -I$PREFIX/include 
export LDFLAGS=${LDFLAGS} -L$PREFIX/lib


${CXX} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS} src/main.cpp src/QSufSort.c -o fmsi
install -d "${PREFIX}/bin"
install fmsi "${PREFIX}/bin/"
