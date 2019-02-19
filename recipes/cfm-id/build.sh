#!/bin/bash

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="-L${PREFIX}/lib"
export CPPFLAGS="-I${PREFIX}/include"

mkdir -p $PREFIX/include/rdkit/External/INCHI-API
cp $PREFIX/include/rdkit/GraphMol/inchi.h $PREFIX/include/rdkit/External/INCHI-API

>&2 ls $PREFIX/lib
>&2 cat CMakeLists.txt

mkdir build
cd build

cmake .. -DCMAKE_INSTALL_PREFIX=$PREFIX -DLPSOLVE_INCLUDE_DIR="${PREFIX}/include/lpsolve" -DLPSOLVE_LIBRARY_DIR="${PREFIX}/lib" -DBoost_INCLUDE_DIR="${PREFIX}/include" -DBOOST_LIBRARYDIR="${PREFIX}/lib" -DRDKIT_INCLUDE_DIR="${PREFIX}/include/rdkit" -DRDKIT_INCLUDE_EXT_DIR="${PREFIX}/include/rdkit/External" #-DRDKIT_LIBRARIES="${PREFIX}/lib"

make VERBOSE=1
make install

# >&2 nm $PREFIX/lib/libRD* 
