#!/bin/bash
set -xe

mkdir -p "${PREFIX}/share/.cache/torch"
OS=$(uname -s)
ARCH=$(uname -m)

export CXXFLAGS="${CXXFLAGS} -O3 -Wno-deprecated-declarations"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

case "${ARCH}" in
    aarch64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8-a"
	;;
    arm64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8.4-a"
	;;
    x86_64)
	export CXXFLAGS="${CXXFLAGS} -march=x86-64-v3"
	;;
esac

CMAKE_ARGS=(
	-DCMAKE_BUILD_TYPE=Release
	-DGUI=OFF
	-DCUDA=OFF
	-DCMAKE_INSTALL_PREFIX="${PREFIX}"
	-DCMAKE_CXX_COMPILER="${CXX}"
	-DCMAKE_CXX_FLAGS="${CXXFLAGS}"
	-DTORCH_HOME_PATH="${PREFIX}/share/.cache/torch"
	-DFETCH_WEIGHTS=OFF
	-DPYTHON_EXE_PATH="$(command -v python3)"
	-Wno-dev -Wno-deprecated
	--no-warn-unused-cli
)

if [[ "${OS}" == "Darwin" ]]; then
	CMAKE_ARGS+=(
		-DCMAKE_FIND_FRAMEWORK=NEVER
		-DCMAKE_FIND_APPBUNDLE=NEVER
	)
fi

if [[ "${ARCH}" == "x86_64" ]]; then
	CMAKE_ARGS+=(
		-DALTCPU=ON
	)
fi

cmake -S . -B build "${CMAKE_ARGS[@]}"
cmake --build build --target install -j "${CPU_COUNT}"
