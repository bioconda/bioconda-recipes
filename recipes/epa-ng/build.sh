#!/bin/bash

# Make m4 accessible to bison
# https://github.com/conda-forge/bison-feedstock/issues/7#issuecomment-431602144
export M4=m4
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export CPP_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include

export CXXFLAGS="${CXXFLAGS} -fsigned-char"

make build/CMakeCache.txt CXXFLAGS="${CXXFLAGS}"

patch -p1 < ${RECIPE_DIR}/genesis.patch
patch -p1 < ${RECIPE_DIR}/pll_modules.patch

make run_make CXXFLAGS="${CXXFLAGS}"


mkdir -p $PREFIX/bin

cp bin/epa-ng $PREFIX/bin

