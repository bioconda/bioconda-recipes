#!/usr/bin/env bash
set -xeu -o pipefail

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"

if [[ `uname` == "Darwin" ]]; then
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
	export CONFIG_ARGS=""
fi

cmake -S . -B build \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS} -O3 -I${PREFIX}/include" \
	-DBOOST_ROOT="${PREFIX}" \
	-DBoost_NO_SYSTEM_PATHS=ON \
	"${CONFIG_ARGS}"

cmake --build build --target install -j 1
