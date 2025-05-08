#!/bin/bash
set -xe

mkdir -p "${PREFIX}/bin"

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3 -Wno-format -std=c++03"

sed -i.bak -e 's|"stdafx.h"|"../apps/snap/stdafx.h"|' tests/*.cpp
sed -i.bak -e 's|"AffineGap.h"|"../SNAPLib/stdafx.h"|' tests/*.cpp
rm -rf tests/*.bak
sed -i.bak -e 's|"-std=c++98"|"-std=c++03"|' Makefile
rm -rf *.bak

make CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" -j"${CPU_COUNT}"
install -v -m 0755 snap-aligner "${PREFIX}/bin"
