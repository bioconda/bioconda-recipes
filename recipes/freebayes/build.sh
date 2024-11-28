#!/bin/bash

mkdir -p ${PREFIX}/bin

cd freebayes
mkdir build

export INCLUDES="-I{PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3 -I{PREFIX}/include"

CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" CC="${CC}" meson setup --buildtype release \
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

chmod 0755 ${PREFIX}/bin/freebayes
chmod 0755 ../scripts/freebayes-parallel
cp -nf ../scripts/freebayes-parallel ${PREFIX}/bin
