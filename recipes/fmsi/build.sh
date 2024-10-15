#!/bin/bash

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L$PREFIX/lib"
export CXXFLAGS="${CXXFLAGS} -O3 -I$PREFIX/include" 

make CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" \
	CPPFLAGS="${CPPFLAGS}" LDFLAGS="${LDFLAGS}" \
	INCLUDES="${INCLUDES}" INCLUDES-PATH="${PREFIX}" \
	-j"${CPU_COUNT}"

install -d "${PREFIX}/bin"
install fmsi "${PREFIX}/bin"
