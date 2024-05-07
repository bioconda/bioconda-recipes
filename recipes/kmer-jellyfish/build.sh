#!/bin/bash

./configure --prefix=${PREFIX} --enable-python-binding --with-sse \
	CXX="${CXX}" CXXFLAGS="${CXXFLAGS} -O3" CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include" \
	LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

make -j ${CPU_COUNT}
make install
