#!/bin/bash -euo

mkdir -p "${PREFIX}/bin"

export INCLUDES="-I{PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

make CC="${CC} -O3 ${LDFLAGS}" CFLAGS="${CFLAGS}" CXX="${CXX}" \
	CXXFLAGS="${CXXFLAGS} -O3 -I{PREFIX}/include" \
	CPP="${CXX}" CPPFLAGS="${CXXFLAGS} -O3 -I${PREFIX}/include" \
	INCLUDES="${INCLUDES}" COMMONLIBS="${COMMONLIBS} -L${PREFIX}/lib" -j"${CPU_COUNT}"

chmod 0755 MuSE
cp -f MuSE "${PREFIX}/bin"
