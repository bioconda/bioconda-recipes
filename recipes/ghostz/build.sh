#!/bin/bash

mkdir -p "${PREFIX}/bin"

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"

make -e CC="${CC}" CXX="${CXX}" LAST_CC="${CXX}" \
	INCLUDES="-I${PREFIX}/include" LDFLAGS="${LDFLAGS}" \
	-j"${CPU_COUNT}"

"${STRIP}" ghostz

install -v -m 0755 ghostz "${PREFIX}/bin"
