#!/bin/bash

export M4="${BUILD_PREFIX}/bin/m4"
export CFLAGS="${CFLAGS} -O3"
export CXXFLAGS="${CXXFLAGS} -O3 -std=c++14"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

# use newer config.guess and config.sub that support linux-aarch64
cp -rf ${RECIPE_DIR}/config.* .

autoreconf -if
./configure --prefix="${PREFIX}" --disable-option-checking \
	--enable-silent-rules --disable-dependency-tracking \
	CC="${CC}" CXX="${CXX}" CFLAGS="${CFLAGS}" \
	CXXFLAGS="${CXXFLAGS}" CPPFLAGS="${CPPFLAGS}" LDFLAGS="${LDFLAGS}"

make -j"${CPU_COUNT}"
make install
ln -sf ${PREFIX}/bin/clustalw2 ${PREFIX}/bin/clustalw
