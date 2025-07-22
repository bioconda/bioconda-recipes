#!/bin/bash
set -xe

mkdir -p "$PREFIX/bin"

export CPATH="${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -fPIC -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3 -Wno-unused-variable"

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

if [[ "$(uname -s)" == "Darwin" ]]; then
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
	export CXXFLAGS="${CXXFLAGS} -O3 -D_LIBCPP_DISABLE_AVAILABILITY"
else
	export CONFIG_ARGS=""
fi

cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_CXX_COMPILER="${CXX}" -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
	-Wno-dev -Wno-deprecated --no-warn-unused-cli \
	"${CONFIG_ARGS}"

ninja -C build -j"${CPU_COUNT}"

install -v -m 755 build/bin/metaMDBG "${PREFIX}/bin"
