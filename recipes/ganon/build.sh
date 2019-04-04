#!/bin/bash

set -x -e

# clone sdsl-lite 3 and specific seqan branch (checkout working commits)
git clone https://github.com/xxsds/sdsl-lite libs/sdsl-lite
cd ${SRC_DIR}/libs/sdsl-lite
git checkout d6ed14d5d731ed4a4ec12627c1ed7154b396af48
cd ${SRC_DIR}
git clone -b SeqAn https://github.com/eseiler/seqan libs/seqan
cd ${SRC_DIR}/libs/seqan
git checkout c308e99f10d942382d4c7ed6fc91be1a889e644c
cd ${SRC_DIR}

mkdir ${SRC_DIR}/build
cd ${SRC_DIR}/build
cmake -DCMAKE_BUILD_TYPE=Release -DVERBOSE_CONFIG=ON -DGANON_OFFSET=OFF -DINCLUDE_DIRS=${PREFIX}/include ..
make
ctest -VV .

mkdir -p ${PREFIX}/bin
cp ${SRC_DIR}/ganon ${SRC_DIR}/build/ganon-build ${SRC_DIR}/build/ganon-classify ${SRC_DIR}/scripts/ganon-get-len-taxid.sh ${PREFIX}/bin/

