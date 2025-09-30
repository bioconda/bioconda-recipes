#!/bin/bash

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"

mkdir -p $PREFIX/bin

cd src

case $(uname -m) in
    aarch64)
	sed -i.bak 's|-march=x86-64-v3|-march=armv8-a|' makefile
	sed -i.bak 's|-mcmodel=medium||' makefile
	rm -f *.bak
	;;
    arm64)
	sed -i.bak 's|-march=x86-64-v3|-march=armv8.4-a|' makefile
	sed -i.bak 's|-mcmodel=medium||' makefile
	rm -f *.bak
	;;
esac

make CXX="${CXX}" -j"${CPU_COUNT}"

install -v -m 0755 rnabridge-* "$PREFIX/bin"
