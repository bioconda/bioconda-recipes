#!/bin/bash
set -eu -o pipefail

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3"
export CXXFLAGS="${CXXFLAGS} -O3"

if [[ `uname` == "Darwin" ]]; then
	export CFLAGS="${CFLAGS} -Wno-unused-command-line-argument -Wno-unused-parameter -Wno-array-bounds"
	export CONFIG_ARGS="-DCMAKE_OSX_DEPLOYMENT_TARGET=10.15 -DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
	export LDFLAGS="${LDFLAGS} -Wl,-rpath,${PREFIX}/lib"
else
	export CONFIG_ARGS=""
fi

cmake -S . -B build -DCMAKE_BUILD_TYPE=Release \
	-DCONDA_BUILD=TRUE \
	-DNO_IPO=TRUE \
	-DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
	-DCMAKE_C_COMPILER="${CC}" \
	-DCMAKE_C_FLAGS="${CFLAGS}" \
	-DBOOST_ROOT="${PREFIX}" \
	-DBoost_NO_SYSTEM_PATHS=ON \
	-DCEREAL_INCLUDE_DIR="${PREFIX}/include" \
	-DLIB_GFF_INCLUDE_DIR="${PREFIX}/include" \
	-DLIBSTADEN_LDFLAGS="-L${PREFIX}/lib" \
	-Wno-dev -Wno-deprecated --no-warn-unused-cli \
	"${CONFIG_ARGS}"

cmake --build build --clean-first --target install -j "${CPU_COUNT}"
