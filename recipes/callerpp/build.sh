#!/bin/bash
set -x -e -o pipefail

mkdir -p "${PREFIX}/bin"

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -g -Wall -O3"

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
	export ARCH_OPTS="-fsigned-char"
	;;
    *)
	export ARCH_OPTS=""
	;;
esac

make CXX="${CXX} -std=c++11 ${ARCH_OPTS}" \
  CXX_FLAGS="${CXXFLAGS} -I${PREFIX}/include ${LDFLAGS}"

install -v -m 0755 bin/callerpp "${PREFIX}/bin"
