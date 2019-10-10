#!/bin/bash

set -x -e

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"

export LDFLAGS="-L${PREFIX}/lib"
export CPPFLAGS="-I${PREFIX}/include"

export CXXFLAGS="${LDFLAGS} ${CPPFLAGS}"

export WORK_DIR=$(pwd)

mkdir -p ${PREFIX}/bin

#cp -rf ${RECIPE_DIR}/TERefiner/* ./TERefiner/

cd TERefiner
make
cd ${WORK_DIR} 

chmod 777 TERefiner_1

cd ./ContigsCompactor-v0.2.0/ContigsMerger/ 
make
cd ${WORK_DIR} 

cp -rf ./TERefiner/* ${PREFIX}/bin/ 

cp -rf ./ContigsCompactor-v0.2.0/ContigsMerger/* ${PREFIX}/bin 

chmod +x ${PREFIX}/bin/TERefiner_1
chmod +x ${PREFIX}/bin/ContigsMerger


