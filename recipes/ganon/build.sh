#!/bin/bash

set -x -e

rm -r ${SRC_DIR}/libs/*

git init

# add submodule for sdsl-lite 3 and specific seqan branch (checkout working commits)
git submodule add https://github.com/xxsds/sdsl-lite libs/sdsl-lite
cd ${SRC_DIR}/libs/sdsl-lite
git checkout d6ed14d5d731ed4a4ec12627c1ed7154b396af48
cd ${SRC_DIR}
git submodule add -b SeqAn https://github.com/eseiler/seqan libs/seqan
cd ${SRC_DIR}/libs/seqan
git checkout c308e99f10d942382d4c7ed6fc91be1a889e644c
cd ${SRC_DIR}

# libs available on conda-forge added with -DINCLUDE_DIRS=${PREFIX}/include 
#git submodule add https://github.com/jarro2783/cxxopts.git libs/cxxopts
#cd ${SRC_DIR}/libs/cxxopts
#git checkout 3876c0907237e5fa89c5850ed1ee688a3bcb62b3
#cd ${SRC_DIR}
#git submodule add https://github.com/catchorg/Catch2.git libs/Catch2
#cd ${SRC_DIR}/libs/Catch2
#git checkout 08147a23f923103c87d1eac3dc30a9ecc4a753c4
#cd ${SRC_DIR}

mkdir ${SRC_DIR}/build
cd ${SRC_DIR}/build
cmake -DCMAKE_BUILD_TYPE=Release -DVERBOSE_CONFIG=ON -DGANON_OFFSET=OFF -DINCLUDE_DIRS=${PREFIX}/include ..
make
ctest -VV .

mkdir -p ${PREFIX}/bin
cp ${SRC_DIR}/ganon ${SRC_DIR}/build/ganon-build ${SRC_DIR}/build/ganon-classify ${PREFIX}/bin/

