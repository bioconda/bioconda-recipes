#!/bin/bash

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="-L${PREFIX}/lib"
export CPPFLAGS="-I${PREFIX}/include"

mkdir -p $PREFIX/include/rdkit/External/INCHI-API
cp $PREFIX/include/rdkit/GraphMol/inchi.h $PREFIX/include/rdkit/External/INCHI-API

mkdir build
cd build

# TODO remove DCMAKE_INSTALL_PREFIX?
# TODO include optional cfm-train and cfm-test -- brings additional dependencies for MPI and liblbfgs-1.10
cmake .. -DCMAKE_INSTALL_PREFIX=$PREFIX \
#	-DINCLUDE_TESTS=ON -DINCLUDE_TRAIN=ON \
        -DLPSOLVE_INCLUDE_DIR="${PREFIX}/include/lpsolve" \
        -DLPSOLVE_LIBRARY_DIR="${PREFIX}/lib" \
        -DBoost_INCLUDE_DIR="${PREFIX}/include" \
	-DBOOST_LIBRARYDIR="${PREFIX}/lib" \
        -DRDKIT_INCLUDE_DIR="${PREFIX}/include/rdkit" \
	-DRDKIT_INCLUDE_EXT_DIR="${PREFIX}/include/rdkit/External" 
#-DRDKIT_LIBRARIES="${PREFIX}/lib"

make 
make install

>&2 echo "parent dir"
>&2 ls ../
>&2 echo "current dir"
>&2 ls ../
>&2 tree ../

# cp binaries 
# cfm-annotate, cfm-id, cfm-id-precomputed, cfm-predict, compute-stats, fraggraph-gen, ISOTOPE.DAT
# TODO what is the DAT file
cp ../bin/* $PREFIX/bin/

# >&2 nm $PREFIX/lib/libRD* 
