#!/bin/bash

#export C_INCLUDE_PATH=$PREFIX/include
#export CPLUS_INCLUDE_PATH=$PREFIX/include

mkdir build
meson build/ --buildtype debug --prefix "${PREFIX}"



cd build
ninja -v

ninja -v install

##Copy scripts over ## This will likely need to be removed with an updated build
cp -n ../scripts/*.py $PREFIX/bin
cp -n ../scripts/*.sh $PREFIX/bin
cp -n ../scripts/*.pl $PREFIX/bin 
#cp -n ../scripts/*.R $PREFIX/bin

cp -n ../scripts/freebayes-parallel $PREFIX/bin
