#!/bin/bash
set -x

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

export CXXFLAGS="${CXXFLAGS} -O3 -D_FILE_OFFSET_BITS=64"

if [ `uname` == Darwin ]; then
	# See https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk for -D_LIBCPP_DISABLE_AVAILABILITY
	export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
	export CONFIG_ARGS="-DBUILD_SHARED_LIBS=ON -DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
	else
	export CONFIG_ARGS="-DBUILD_SHARED_LIBS=ON"
fi

mkdir -p "${PREFIX}/bin"

cmake -S . -B build \
	-DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_C_COMPILER="${CC}" \
	-DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
	-DCMAKE_INSTALL_LIBDIR=lib "${CONFIG_ARGS}"

cmake --build build/ --target install -j "${CPU_COUNT}"
