#!/usr/bin/env bash

set -euxo pipefail

if [[ "$(uname)" == "Darwin" ]]; then
  export LDFLAGS="${LDFLAGS} -undefined dynamic_lookup -Wl,-export_dynamic"
elif [[ "$(uname)" == "Linux" ]]; then
  export LDFLAGS="${LDFLAGS} -Wl,--allow-shlib-undefined,--export-dynamic"
fi

mkdir -p build && cd build

cmake .. \
    ${CMAKE_ARGS} \
    -DCMAKE_PREFIX_PATH=${PREFIX} \
    -DCMAKE_CXX_STANDARD=17 \
    -DBOOST_ROOT=${PREFIX} \
    -DENABLE_GUI=OFF \
    -DENABLE_GFX=OFF \
    -DENABLE_INFO=OFF \
    -DUSE_RPATH=ON \
    -DCMAKE_VERBOSE_MAKEFILE=ON

make VERBOSE=1 -j"${CPU_COUNT}"

cp ../monomers/components.cif.gz .
stage/bin/chemdict_tool create components.cif.gz compounds.chemlib pdb -i
stage/bin/chemdict_tool update ../modules/conop/data/charmm.cif compounds.chemlib charmm

cmake .. \
    ${CMAKE_ARGS} \
    -DCMAKE_PREFIX_PATH=${PREFIX} \
    -DCMAKE_CXX_STANDARD=17 \
    -DBOOST_ROOT=${PREFIX} \
    -DCOMPOUND_LIB=${SRC_DIR}/build/compounds.chemlib \
    -DPARASAIL_INCLUDE_DIR=${SP_DIR}/parasail/include \
    -DPARASAIL_LIBRARY=${SP_DIR}/parasail/libparasail.${SHLIB_EXT} \
    -DUSE_RPATH=ON \
    -DOPTIMIZE=ON \
    -DENABLE_PARASAIL=ON \
    -DCOMPILE_TMTOOLS=OFF \
    -DENABLE_GFX=ON \
    -DENABLE_GUI=ON \
    -DENABLE_INFO=ON \
    -DUSE_SHADER=ON \
    -DUSE_DOUBLE_PRECISION=OFF \
    -DENABLE_MM=ON \
    -DOPEN_MM_LIBRARY=${PREFIX}/lib/libOpenMM.${SHLIB_EXT} \
    -DOPEN_MM_INCLUDE_DIR=${PREFIX}/include \
    -DOPEN_MM_PLUGIN_DIR=${PREFIX}/lib/plugins \
    -DCMAKE_VERBOSE_MAKEFILE=ON

make VERBOSE=1 -j"${CPU_COUNT}"
make check
make install
