#!/bin/bash

rm -r libs/*
git init
# add submodule for sdsl-lite 3 and specific seqan branch
git submodule add https://github.com/xxsds/sdsl-lite libs/sdsl-lite
git submodule add -b SeqAn https://github.com/eseiler/seqan libs/seqan
# those libs are coming from the system
git submodule add https://github.com/jarro2783/cxxopts.git libs/cxxopts
git submodule add https://github.com/catchorg/Catch2.git libs/Catch2

set -x -e

mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release -DVERBOSE_CONFIG=ON -DGANON_OFFSET=OFF -DUSE_MODULES=OFF ..
make

ctest -VV .

mkdir -p ${PREFIX}/bin
cp ../ganon ganon-build ganon-classify ${PREFIX}/bin/

