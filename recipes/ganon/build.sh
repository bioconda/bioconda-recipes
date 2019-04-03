#!/bin/bash

rm -r libs/*

git init

git submodule add https://github.com/xxsds/sdsl-lite libs/sdsl-lite
git submodule add -b SeqAn https://github.com/eseiler/seqan libs/seqan
#git submodule add https://github.com/jarro2783/cxxopts.git libs/cxxopts
git submodule add https://github.com/catchorg/Catch2.git libs/Catch2

mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release -DVERBOSE_CONFIG=ON -DGANON_OFFSET=OFF ..
make

ctest -VV .

mkdir -p ${PREFIX}/bin
cp ../ganon ganon-build ganon-classify ${PREFIX}/bin/

