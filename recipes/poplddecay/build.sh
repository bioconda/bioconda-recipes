#!/bin/bash -euo

mkdir -p ${PREFIX}/bin

export M4="${BUILD_PREFIX}/bin/m4"
export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3 -I${PREFIX}/include"

autoreconf -if
./configure CXX="${CXX}" \
	CXXFLAGS="${CXXFLAGS}" \
	LDFLAGS="${LDFLAGS}" \
	--prefix="${PREFIX}"

make -j"${CPU_COUNT}"

chmod 0755 PopLDdecay
cp -rf PopLDdecay ${PREFIX}/bin
