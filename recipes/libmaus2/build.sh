#!/bin/bash
set -eu

export LIBS="-lstdc++fs -lcurl"

./configure --prefix "${PREFIX}" \
	CXX="${CXX}" CXXFLAGS="${CXXFLAGS} -O3 -I${PREFIX}/include" \
	LDFLAGS="${LDFLAGS} -L${PREFIX}/lib" \
	--with-snappy --with-io_lib

cat config.log

make -j${CPU_COUNT}
make install
