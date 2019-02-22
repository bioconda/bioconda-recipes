#!/bin/bash

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="-L${PREFIX}/lib"
export CPPFLAGS="-I${PREFIX}/include"

mkdir -p "$PREFIX/include/rdkit/External/INCHI-API"
cp "$PREFIX/include/rdkit/GraphMol/inchi.h" "$PREFIX/include/rdkit/External/INCHI-API"

mkdir build
cd build

# TODO include optional cfm-train and cfm-test 
# - brings additional dependencies for MPI (mpich2) and liblbfgs-1.10 (not yet in conda)
cmake .. -DLPSOLVE_INCLUDE_DIR="${PREFIX}/include/lpsolve" \
        -DLPSOLVE_LIBRARY_DIR="${PREFIX}/lib" \
        -DBoost_INCLUDE_DIR="${PREFIX}/include" \
        -DBOOST_LIBRARYDIR="${PREFIX}/lib" \
        -DRDKIT_INCLUDE_DIR="${PREFIX}/include/rdkit" \
        -DRDKIT_INCLUDE_EXT_DIR="${PREFIX}/include/rdkit/External" 
#-DINCLUDE_TESTS=ON -DINCLUDE_TRAIN=ON \
#-DRDKIT_LIBRARIES="${PREFIX}/lib"

make 
make install

# cp binaries 
# cfm-annotate, cfm-id, cfm-id-precomputed, cfm-predict, compute-stats, fraggraph-gen, ISOTOPE.DAT
cp ../bin/* "$PREFIX"/bin/
