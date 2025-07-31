#!/bin/bash

mkdir -p "${PREFIX}/bin"

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"

if [[ "$(uname -s)" == "Darwin" ]]; then
	sed -i.bak 's|tr1/memory|memory|' src/aligner.h
	sed -i.bak 's|tr1/memory|memory|' ext/seg/src/seg.h
fi

make -e CC="${CC}" CXX="${CXX}" LAST_CC="${CXX}" \
	INCLUDES="-I${PREFIX}/include" LDFLAGS="${LDFLAGS}" \
	-j"${CPU_COUNT}"

"${STRIP}" ghostz

install -v -m 0755 ghostz "${PREFIX}/bin"
