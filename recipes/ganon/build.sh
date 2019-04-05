#!/bin/bash

set -x -e

ls -lah ${SRC_DIR}/*

mv ${SRC_DIR}/seqan ${SRC_DIR}/ganon/libs/
mv ${SRC_DIR}/sdsl-lite ${SRC_DIR}/ganon/libs/

mkdir ${SRC_DIR}/ganon/build
cd ${SRC_DIR}/ganon/build
cmake -DCMAKE_BUILD_TYPE=Release -DVERBOSE_CONFIG=ON -DGANON_OFFSET=OFF -DINCLUDE_DIRS=${PREFIX}/include ..
make
ctest -VV .

mkdir -p ${PREFIX}/bin
cp ${SRC_DIR}/ganon/ganon ${SRC_DIR}/ganon/build/ganon-build ${SRC_DIR}/ganon/build/ganon-classify ${SRC_DIR}/ganon/scripts/ganon-get-len-taxid.sh ${PREFIX}/bin/

