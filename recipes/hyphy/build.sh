#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -fPIC -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3 -Wno-unused-variable"

if [[ `uname -s` == "Darwin" ]]; then
    export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
    export CONFIG_ARGS=""
fi

case $(uname -m) in
    aarch64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8-a"
    export HYPHY_OPTS="-DNOSSE4=ON"
	;;
    arm64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8.4-a"
    export HYPHY_OPTS="-DNOSSE4=ON"
	;;
    x86_64)
	export CXXFLAGS="${CXXFLAGS} -march=x86-64-v3"
    export HYPHY_OPTS="-DNOAVX=ON"
	;;
esac

OS=$(uname -s)
ARCH=$(uname -m)

if [[ "${OS}" == "Darwin" && "${ARCH}" == "arm64" ]]; then
    export HYPHY_OPTS="${HYPHY_OPTS}"
elif [[ "${OS}" == "Linux" && "${ARCH}" == "aarch64" ]]; then
    export HYPHY_OPTS="${HYPHY_OPTS}"
elif [[ "${OS}" == "Darwin" && "${ARCH}" == "x86_64" ]]; then
    export HYPHY_OPTS="${HYPHY_OPTS} -DNONEON=ON"
elif [[ "${OS}" == "Linux" && "${ARCH}" == "x86_64" ]]; then
    export HYPHY_OPTS="${HYPHY_OPTS} -DNONEON=ON"
fi

cmake -S . -B build -G Ninja -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER="${CXX}" \
    -DCMAKE_CXX_FLAGS="${CXXFLAGS}" -Wno-dev \
    -Wno-deprecated --no-warn-unused-cli \
    "${HYPHY_OPTS}" \
    "${CONFIG_ARGS}"
ninja -C build -j"${CPU_COUNT}" HYPHYMPI
ninja -C build -j"${CPU_COUNT}" install
