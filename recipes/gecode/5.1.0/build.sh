#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I$PREFIX/include"
export CFLAGS="${CFLAGS} -O3 -Wno-deprecated-declarations"
export CXXFLAGS="${CXXFLAGS} -O3 -Wno-maybe-uninitialized -Wno-unused-result -Wno-register"

cp -f ${BUILD_PREFIX}/share/gnuconfig/config.* .

autoreconf -if
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

case $(uname -s) in
    "Darwin")
        export CXXFLAGS="${CXXFLAGS} -std=c++03"
        export EXTRA_ARGS="--disable-cpp11"
        ;;
    "Linux")
        export CXXFLAGS="${CXXFLAGS} -std=c++14"
        export EXTRA_ARGS=""
        ;;
esac

./configure --prefix="${PREFIX}" \
	--disable-qt \
	--disable-option-checking \
	CXX="${CXX}" \
	CXXFLAGS="${CXXFLAGS}" \
	CPPFLAGS="${CPPFLAGS}" \
	LDFLAGS="${LDFLAGS}" \
	"${EXTRA_ARGS}"

make -j"${CPU_COUNT}"
make install
