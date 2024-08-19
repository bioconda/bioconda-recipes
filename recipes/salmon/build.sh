#!/bin/bash
set -eu -o pipefail

export INCLUDES="-I{PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3 ${LDFLAGS}"
export CXXFLAGS="${CXXFLAGS} -O3 -I${PREFIX}/include"

if [[ `uname` == "Darwin" ]]; then
	export CFLAGS="${CFLAGS} -Wunused-command-line-argument -Wunused-parameter"
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
	export CONFIG_ARGS=""
fi

cmake -S . -B build \
	-DCMAKE_INSTALL_PREFIX:PATH="${PREFIX}" \
	-DCMAKE_BUILD_TYPE=RELEASE \
	-DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
	-DCMAKE_C_COMPILER="${CC}" \
	-DCMAKE_C_FLAGS="${CFLAGS}" \
	-DCONDA_BUILD=TRUE \
	-DSTADEN_INCLUDE_DIR="${PREFIX}/include" \
	-DSTADEN_LIBRARY="${PREFIX}/lib" \
	-DSTADEN_VERSION="1.15.0" \
	-DBOOST_ROOT="${PREFIX}" \
	-DNO_IPO=TRUE \
	-DBUILD_SHARED_LIBS=ON "${CONFIG_ARGS}"

cmake --build build/ --target install -v
