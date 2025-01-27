#!/bin/bash

mkdir -p "${PREFIX}/bin"

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export CFLAGS="$CFLAGS -O3 -L$PREFIX/lib"
export CPPFLAGS="$CPPFLAGS -L$PREFIX/include"
export CXXFLAGS="$CXXFLAGS -O3 -Wno-unused-command-line-argument"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"

case $(uname -m) in
	arm64) EXTRA_ARGS="arm_neon=1 aarch64=1" ;;
	aarch64) EXTRA_ARGS"aarch64=1" ;;
esac

make PREFIX="${PREFIX}" CC="${CC}" CXX="${CXX}" \
	CXXFLAGS="${CXXFLAGS}" LD_FLAGS="${LDFLAGS}" \
	${EXTRA_ARGS} -j"${CPU_COUNT}"

install -v -m 0755 tgsgapcloserbin/* "${PREFIX}/bin"
