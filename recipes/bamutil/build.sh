#!/usr/bin/env bash
set -xe

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3"
export CFLAGS="${CFLAGS} -O3"

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

cd bamUtil

make -j"${CPU_COUNT}" \
    CXX="${CXX} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS} -std=c++11" \
    CC="${CC} ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}" \
    USER_WARNINGS='-Wno-strict-overflow' \
    INSTALLDIR="${PREFIX}/bin" \
    install
