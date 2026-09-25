#!/bin/bash -e

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

mkdir -p "${PREFIX}/bin"

case $(uname -m) in
    aarch64)
	sed -i.bak 's|-march=x86-64-v3|-march=armv8-a|' Makefile
	;;
    arm64)
	sed -i.bak 's|-march=x86-64-v3|-march=armv8.4-a|' Makefile
	;;
esac

case $(uname -s) in
    Darwin)
        sed -i.bak 's|-lstdc++|-lc++|' Makefile
        ;;
esac

rm -f *.bak

make SRA_PATH="${PREFIX}" -j"${CPU_COUNT}"

install -v -m 0755 sracat "${PREFIX}/bin"
