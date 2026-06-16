#!/bin/bash

install -d "${PREFIX}/bin"

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3 -std=c++03 -Wno-register -I."

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

make CPP="${CXX}" CPPFLAGS="${CXXFLAGS}"

install -v -m 0755 BaitFisher-v1.2.7 "${PREFIX}/bin/BaitFisher"
install -v -m 0755 BaitFilter-v1.0.5 "${PREFIX}/bin/BaitFilter"
