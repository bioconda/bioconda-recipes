#!/bin/bash

mkdir -p ${PREFIX}/bin

cd freebayes
mkdir build

export C_INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3 -Wno-deprecated-declarations"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"

wget -O src/multipermute.h https://raw.githubusercontent.com/ekg/multipermute/refs/heads/master/multipermute.h

sed -i.bak -e 's|"split.h"|<vcflib/split.h>|' src/*.h
sed -i.bak -e 's|"split.h"|<vcflib/split.h>|' src/*.cpp
sed -i.bak -e 's|"convert.h"|<vcflib/convert.h>|' src/*.h
sed -i.bak -e 's|"convert.h"|<vcflib/convert.h>|' src/*.cpp
sed -i.bak -e 's|"join.h"|<vcflib/join.h>|' src/*.h
sed -i.bak -e 's|"join.h"|<vcflib/join.h>|' src/*.cpp
sed -i.bak -e 's|"multichoose.h"|<vcflib/multichoose.h>|' src/*.h
sed -i.bak -e 's|"multichoose.h"|<vcflib/multichoose.h>|' src/*.cpp
sed -i.bak -e 's|<Variant.h>|<vcflib/Variant.h>|' src/*.h
sed -i.bak -e 's|<intervaltree/IntervalTree.h>|<vcflib/IntervalTree.h>|' src/BedReader.h
sed -i.bak -e 's|<IntervalTree.h>|<vcflib/IntervalTree.h>|' src/BedReader.cpp

rm -rf src/*.bak

OS=$(uname)
ARCH=$(uname -m)

if [[ "${OS}" == "Darwin" && "${ARCH}" == "x86_64" ]]; then
	export CXXFLAGS="${CXXFLAGS} -arch x86_64"
elif [[ "${OS}" == "Darwin" && "${ARCH}" == "arm64" ]]; then
	export CXXFLAGS="${CXXFLAGS} -arch arm64"
fi

CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" LDFLAGS="${LDFLAGS}" meson setup --buildtype release \
	--prefix "${PREFIX}" --strip \
	--includedir "${PREFIX}/include" \
	--libdir "${PREFIX}/lib" build/

cd build
ninja -v

ninja -v install

## Copy scripts over to ${PREFIX}/bin ##
chmod 0755 ../scripts/*.py
chmod 0755 ../scripts/*.sh
chmod 0755 ../scripts/*.pl
cp -nf ../scripts/*.py ${PREFIX}/bin
cp -nf ../scripts/*.sh ${PREFIX}/bin
cp -nf ../scripts/*.pl ${PREFIX}/bin
cp -nf ../scripts/freebayes-parallel ${PREFIX}/bin

chmod 0755 ${PREFIX}/bin/freebayes
chmod 0755 ${PREFIX}/bin/freebayes-parallel
