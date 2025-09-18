#!/bin/bash
set -x

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"

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

install -d "${PREFIX}/bin"

if [[ "${target_platform}" =~ linux.* ]]; then
    make -j"${CPU_COUNT}" -C general CC="${CC}" CXX="${CXX}" DEBUG="${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS} -std=c++03"
    make -j"${CPU_COUNT}" -C bmtagger CC="${CC}" CXX="${CXX}" DEBUG="${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS} -std=c++03"
    cd bmtagger
fi

install -v -m 0755 bmfilter "${PREFIX}/bin"
