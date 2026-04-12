#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"

mkdir -p "${PREFIX}/bin"

sed -i.bak 's|ar rcs|$(AR) rcs|' Makefile

make CC="${CXX}" \
	C="${CC}" \
	FLAGS="${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS} -D_NOSQLITE -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64" \
	INCLUDE="-I${PREFIX}/include -I." \
	-j"${CPU_COUNT}"

install -v -m 0755 kronik "${PREFIX}/bin"
