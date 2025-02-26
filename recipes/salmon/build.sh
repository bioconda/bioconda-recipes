#!/bin/bash
set -eu -o pipefail

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"

if [[ `uname` == "Darwin" ]]; then
	export CFLAGS="${CFLAGS} -Wno-unused-command-line-argument -Wno-unused-parameter -Wno-array-bounds"
	export CONFIG_ARGS="-DCMAKE_OSX_DEPLOYMENT_TARGET=10.15 -DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
	export LDFLAGS="${LDFLAGS} -Wl,-rpath,${PREFIX}/lib"
else
	export CONFIG_ARGS=""
fi

cmake -S . -B build \
	-DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCMAKE_BUILD_TYPE=RELEASE \
	-DCMAKE_C_COMPILER="${CC}" \
	-DCMAKE_C_FLAGS="${CFLAGS}" \
	-DCONDA_BUILD=TRUE \
	-DBOOST_ROOT="${PREFIX}" \
	-DBoost_NO_SYSTEM_PATHS=ON \
	-DCEREAL_INCLUDE_DIR="${PREFIX}/include" \
	-DLIB_GFF_INCLUDE_DIR="${PREFIX}/include" \
	-DLIBSTADEN_LDFLAGS="-L${PREFIX}/lib" \
	-DNO_IPO=TRUE \
	"${CONFIG_ARGS}"

cmake --build build/ --target install
