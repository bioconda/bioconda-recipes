#!/bin/bash

mkdir -p ${PREFIX}/bin

mkdir build

export C_INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"

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
sed -i.bak -e 's|<Fasta.h>|"Fasta.h"|' ${PREFIX}/include/vcflib/Variant.h
rm -rf src/*.bak

OS=$(uname -s)
ARCH=$(uname -m)

if [[ "${OS}" == "Darwin" && "${ARCH}" == "x86_64" ]]; then
	export CXXFLAGS="${CXXFLAGS} -arch x86_64"
	sed -i.bak -e 's|c++17|c++14|' meson.build
	rm -rf *.bak
elif [[ "${OS}" == "Darwin" && "${ARCH}" == "arm64" ]]; then
	export CXXFLAGS="${CXXFLAGS} -arch arm64"
	sed -i.bak -e 's|c++17|c++14|' meson.build
	rm -rf *.bak
fi

CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" LDFLAGS="${LDFLAGS}" meson setup --buildtype release \
	--prefix "${PREFIX}" --strip --includedir "${PREFIX}/include" \
	--libdir "${PREFIX}/lib" -Dc_args="-I${PREFIX}/include" \
	-Dc_link_args="-L${PREFIX}/lib" build/

cd build

sed -i.bak -e 's|-I../src|-I../src -I../contrib -I../contrib/SeqLib -I../contrib/fastahack -I../contrib/smithwaterman|' build.ninja
rm -rf *.bak

ninja -v -j"${CPU_COUNT}"
ninja install -v -j"${CPU_COUNT}"

## Copy scripts over to ${PREFIX}/bin ##
install -v -m 0755 ../scripts/*.py "${PREFIX}/bin"
install -v -m 0755 ../scripts/*.sh "${PREFIX}/bin"
install -v -m 0755 ../scripts/*.pl "${PREFIX}/bin"
install -v -m 0755 ../scripts/freebayes-parallel "${PREFIX}/bin"

chmod 0755 "${PREFIX}/bin/freebayes"
