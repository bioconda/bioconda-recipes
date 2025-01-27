#!/bin/bash

mkdir -p "${PREFIX}/bin"

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export CFLAGS="$CFLAGS -O3 -L$PREFIX/lib"
export CPPFLAGS="$CPPFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
export LD_FLAGS="$LD_FLAGS -L$PREFIX/lib"

case $(uname -m) in
	arm64) ARCH_BUILD="arm_neon=1 aarch64=1" ;;
	aarch64) ARCH_BUILD="aarch64=1" ;;
esac

make CC="${CC}" CXX="${CXX}" "${ARCH_BUILD}"

install -v -m 0755 tgsgapcloserbin/* "${PREFIX}/bin"
