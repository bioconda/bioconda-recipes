#!/bin/bash
set -xe

mkdir -p "${PREFIX}/share/.cache/torch"
OS=$(uname -s)
ARCH=$(uname -m)

export CXXFLAGS="${CXXFLAGS} -O3 -Wno-deprecated-declarations"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

case $(uname -m) in
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

if [[ "${OS}" == "Darwin" ]]; then
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
	export CONFIG_ARGS=""
fi

if [[ "${ARCH}" == "x86_64" ]]; then
	export ADDITIONAL_FLAGS="-DALTCPU=ON"
else
 	export ADDITIONAL_FLAGS=""
fi

cmake -S . -B build -DCMAKE_BUILD_TYPE=Release \
	-DGUI=OFF -DCUDA=OFF -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCMAKE_CXX_COMPILER="${CXX}" -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
	-DPYTHON_EXE_PATH="${PYTHON}" -DTORCH_HOME_PATH="${PREFIX}/share/.cache/torch" \
	-DFETCH_WEIGHTS=OFF \
	-Wno-dev -Wno-deprecated --no-warn-unused-cli \
	"${ADDITIONAL_FLAGS}" \
	"${CONFIG_ARGS}"
cmake --build build --target install -j "${CPU_COUNT}"
