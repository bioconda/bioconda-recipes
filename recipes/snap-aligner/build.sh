#!/bin/bash
set -xe

mkdir -p "${PREFIX}/bin"

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"

if [[ "$target_platform" == "linux-aarch64" || "$target_platform" == "osx-arm64" ]]; then
	sed -i.bak 's|-msse||' Makefile
fi
sed -i.bak 's|-ISNAPLib -Iapps/snap|-ISNAPLib -Iapps/snap -O3 -Wno-format -std=c++03|' Makefile
rm -f *.bak

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

make CXX="${CXX}" -j"${CPU_COUNT}"
install -v -m 0755 snap-aligner "${PREFIX}/bin"
