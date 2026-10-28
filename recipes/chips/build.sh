#!/bin/bash

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="$CFLAGS -O3 -I$PREFIX/include"
export CXXFLAGS="$CXXFLAGS -O3 -std=c++14 -D_LIBCPP_DISABLE_AVAILABILITY -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib -lz"

mkdir -p "${PREFIX}/bin"

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

if [[ `uname -s` == "Darwin" ]]; then
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
	export CONFIG_ARGS=""
fi

cmake -S . -B build -DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_CXX_COMPILER="${CXX}" -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
	-Wno-dev -Wno-deprecated --no-warn-unused-cli \
	"${CONFIG_ARGS}"

cd build

make CXX="${CXX} ${CXXFLAGS} ${LDFLAGS}" \
	CC="${CC} ${CFLAGS} ${LDFLAGS}"

install -v -m 0755 chips "${PREFIX}/bin"
