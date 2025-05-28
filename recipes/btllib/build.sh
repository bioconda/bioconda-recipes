#!/bin/bash

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3 -D_LIBCPP_DISABLE_AVAILABILITY"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"

CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" LDFLAGS="${LDFLAGS}" meson setup --buildtype release \
	--prefix "${PREFIX}" --strip -Db_coverage=false build/

cd build

ninja install -v -j"${CPU_COUNT}"

# python wrappers:
${PYTHON} -m pip install "${PREFIX}/lib/btllib/python" --no-deps --no-build-isolation --no-cache-dir -vvv
