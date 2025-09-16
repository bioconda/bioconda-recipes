#!/bin/bash
set -xe

export LDFLAGS="${LDFLAGS} -L$PREFIX/lib"
export CPATH="${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3 -std=c++14"

mkdir -p "$PREFIX/bin"

# The patch does not move the VERSION file on OSX. Let's make sure it's moved.
mv VERSION{,.txt} || True

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

case $(uname -m) in
    aarch64|arm64)
        CXXFLAGS="${CXXFLAGS} -fsigned-char"
        ARCH_OPTS="SSE_FLAG=POPCNT_CAPABILITY=0"
        ;;
    *)
        ARCH_OPTS=""
        ;;
esac

make CXX="${CXX}" RELEASE_FLAGS="${CXXFLAGS}" "${ARCH_OPTS}" -j1
make install prefix="$PREFIX"

install -v -m 0755 evaluation/{centrifuge_evaluate.py,centrifuge_simulate_reads.py} "$PREFIX/bin"
