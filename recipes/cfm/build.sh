#!/bin/bash

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="-L${PREFIX}/lib"
export CPPFLAGS="-I${PREFIX}/include"

echo "PWD $pwd"

ls -la *

find . -type f -exec sed -i 's/\r$//' {} \;
# sed -i 's/\r$//' $RECIPE_DIR/source.patch
patch -p 0 -u < $RECIPE_DIR/source.patch

mkdir -p "$PREFIX/include/rdkit/External/INCHI-API"
cp "$PREFIX/include/rdkit/GraphMol/inchi.h" "$PREFIX/include/rdkit/External/INCHI-API"

mkdir build
cd build

cmake ../cfm/ -DCFM_OUTPUT_DIR="${PREFIX}/bin/" \
        -DLPSOLVE_INCLUDE_DIR="${PREFIX}/include/lpsolve" \
        -DLPSOLVE_LIBRARY_DIR="${PREFIX}/lib" \
        -DBoost_INCLUDE_DIR="${PREFIX}/include" \
        -DBOOST_LIBRARYDIR="${PREFIX}/lib" \
        -DRDKIT_INCLUDE_DIR="${PREFIX}/include/rdkit" \
        -DRDKIT_INCLUDE_EXT_DIR="${PREFIX}/include/rdkit/External" \
        -DLBFGS_INCLUDE_DIR="${PREFIX}/include" -DLBFGS_LIBRARY_DIR="${PREFIX}/lib" \
        -DINCLUDE_TESTS=ON -DINCLUDE_TRAIN=ON
#-DRDKIT_LIBRARIES="${PREFIX}/lib"

make -j$CPU_COUNT VERBOSE=1;
make install VERBOSE=1;

>&2 echo "----------"
>&2 ls ../

>&2 echo "----------"
>&2 ls ./

# cp binaries 
>&2 which cfm-id

