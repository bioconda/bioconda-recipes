#!/bin/bash
set -x
if [[ ${target_platform}  == "linux-aarch64" ]]; then

	export CXXFLAGS="-Wno-return-type -O2 -march=armv8-a"
	sed -i "19a  #include <cstdint>" src/SingleBamRec.h
	sed -i "8a  #include <cstdint>" src/Config.cpp
	sed -i "19a  #include <cstdint>" src/Config.h
fi
mkdir -p "${PREFIX}/bin"
LDADD="${PREFIX}/lib/libbamtools.a ${PREFIX}/lib/libglpk.a"
LDLIBS='-lz -lm'
"${CXX}" \
    ${CPPFLAGS} ${CXXFLAGS} -I"${PREFIX}/include/bamtools" -std=c++11 \
    -o "${PREFIX}/bin/squid" src/*.cpp \
    ${LDFLAGS} ${LDADD} ${LDLIBS}
