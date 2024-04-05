#!/bin/bash

mkdir build
mkdir -p ${PREFIX}/bin

CXX="${CXX}" CC="${CC}" meson setup --buildtype release --prefix "${PREFIX}" \
	--strip --prefer-static -Dprefer_system_deps=true build/

cd build
ninja -v

ninja -v install

##Copy scripts over ## This will likely need to be removed with an updated build
cp -n ../scripts/*.py $PREFIX/bin
cp -n ../scripts/*.sh $PREFIX/bin
cp -n ../scripts/*.pl $PREFIX/bin

cp -n ../scripts/freebayes-parallel $PREFIX/bin
