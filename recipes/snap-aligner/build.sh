#!/bin/bash
set -xe

mkdir -p "${PREFIX}/bin"

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -g -O3 -Wno-format -std=c++03 -ISNAPLib -Iapps/snap"

sed -i.bak -e 's|"stdafx.h"|"../SNAPLib/stdafx.h"|' tests/*.cpp
sed -i.bak -e 's|"AffineGap.h"|"../SNAPLib/AffineGap.h"|' tests/*.cpp
sed -i.bak -e 's|"LandauVishkin.h"|"../SNAPLib/LandauVishkin.h"|' tests/*.cpp
sed -i.bak -e 's|"AffineGapVectorized.h"|"../SNAPLib/AffineGapVectorized.h"|' tests/*.cpp
sed -i.bak -e 's|"Compat.h"|"../SNAPLib/Compat.h"|' tests/*.cpp
rm -rf tests/*.bak

make CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" -j"${CPU_COUNT}"
install -v -m 0755 snap-aligner "${PREFIX}/bin"
