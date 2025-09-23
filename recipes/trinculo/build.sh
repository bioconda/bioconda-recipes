#!/bin/bash

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3 -Wno-deprecated-declarations"

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

mkdir -p "${PREFIX}/bin"

if [[ "${target_platform}" =~ osx.* ]]; then
    "${CXX}" ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS} -framework Accelerate -Isrc -o "${PREFIX}/bin/trinculo" src/trinculo.cpp
else
    "${CXX}" ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS} -DLINUX -Isrc -o "${PREFIX}/bin/trinculo" src/trinculo.cpp -llapack -lpthread
fi
