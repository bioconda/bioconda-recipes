#!/bin/bash


mkdir build
meson build/ --buildtype debug --prefix "${PREFIX}"

cd build
ninja -v
ninja -v install

cp -n ../scripts/*.py $PREFIX/bin
cp -n ../scripts/*.sh $PREFIX/bin
#cp -n ../scripts/*.pl $PREFIX/bin 
#cp -n ../scripts/*.R $PREFIX/bin
cp -n ../scripts/bgziptabix ../scripts/freebayes-parallel $PREFIX/bin








