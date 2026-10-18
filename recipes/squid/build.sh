#!/bin/bash
set -x

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -Wno-return-type -O3"

mkdir -p "${PREFIX}/bin"

if [[ "$(uname -s)" == "Linux" ]]; then
	sed -i "19a  #include <cstdint>" src/SingleBamRec.h
	#sed -i "8a  #include <cstdint>" src/Config.cpp
	sed -i "19a  #include <cstdint>" src/Config.h
fi

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

LDADD="${PREFIX}/lib/libbamtools.a ${PREFIX}/lib/libglpk.a"
LDLIBS='-lz -lm'
"${CXX}" \
    ${CPPFLAGS} ${CXXFLAGS} -I"${PREFIX}/include/bamtools" -std=c++11 \
    -o "${PREFIX}/bin/squid" src/*.cpp \
    ${LDFLAGS} ${LDADD} ${LDLIBS}

chmod 0755 ${PREFIX}/bin/squid
