#!/bin/bash

mkdir build
meson setup --buildtype debug --prefix "${PREFIX}" -Dprefer_system_deps=true build/



cd build
ninja -v

ninja -v install

##Copy scripts over ## This will likely need to be removed with an updated build
cp -n ../scripts/*.py $PREFIX/bin
cp -n ../scripts/*.sh $PREFIX/bin
cp -n ../scripts/*.pl $PREFIX/bin 
#cp -n ../scripts/*.R $PREFIX/bin

cp -n ../scripts/freebayes-parallel $PREFIX/bin
