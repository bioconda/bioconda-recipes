#!/bin/bash

mkdir -p ${PREFIX}/bin

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

make CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" \
	CPPFLAGS="${CPPFLAGS}" LDFLAGS="${LDFLAGS}" \
	-j"${CPU_COUNT}"

chmod 0755 fmsi
mv fmsi ${PREFIX}/bin
