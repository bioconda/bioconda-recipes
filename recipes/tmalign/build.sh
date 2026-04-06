#!/bin/bash

mkdir -p "${PREFIX}/bin"

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3 -ffast-math -Wno-deprecated-declarations"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

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
	make TMalign CC="${CXX}" CFLAGS="${CXXFLAGS}" LDFLAGS="${LDFLAGS}" -j"${CPU_COUNT}"
	make TMscore CC="${CXX}" CFLAGS="${CXXFLAGS}" LDFLAGS="${LDFLAGS}" -j"${CPU_COUNT}"
	install -v -m 0755 TMalign TMscore "${PREFIX}/bin"
else
	"${CXX}" "${CXXFLAGS}" -static -o "${PREFIX}/bin/TMalign" TMalign.cpp
	"${CXX}" "${CXXFLAGS}" -static -o "${PREFIX}/bin/TMscore" TMscore.cpp
fi
