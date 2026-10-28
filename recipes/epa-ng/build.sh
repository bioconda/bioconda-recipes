#!/bin/bash

# Make m4 accessible to bison
# https://github.com/conda-forge/bison-feedstock/issues/7#issuecomment-431602144
export M4=m4
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export CPP_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include

make build/CMakeCache.txt 

patch -p1 < ${RECIPE_DIR}/genesis.patch
patch -p1 < ${RECIPE_DIR}/pll_modules.patch

make -j ${CPU_COUNT} run_make 


mkdir -p $PREFIX/bin

cp bin/epa-ng $PREFIX/bin

