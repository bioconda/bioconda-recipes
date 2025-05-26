#!/usr/bin/env bash

set -exo pipefail

# Prevent build failures due to insufficient memory in the CI environment
if [[ "${build_platform}" == "linux-aarch64" || "${build_platform}" == "osx-arm64" ]]; then
  export CPU_COUNT=1
fi

if [[ "$(uname)" == "Linux" ]]; then
    export LDFLAGS="${LDFLAGS} -Wl,--allow-shlib-undefined,--export-dynamic"
elif [[ "$(uname)" == "Darwin" ]]; then
    export LDFLAGS="${LDFLAGS} -undefined dynamic_lookup -Wl,-export_dynamic -framework OpenGL"
fi

mkdir -p build && cd build

cmake .. \
    ${CMAKE_ARGS} \
    -DCMAKE_PREFIX_PATH="${PREFIX}" \
    -DCMAKE_CXX_COMPILER="${CXX}" \
    -DCXX_FLAGS="${CXXFLAGS}" \
    -DCMAKE_CXX_STANDARD=17 \
    -DBOOST_ROOT="${PREFIX}" \
    -DBoost_INCLUDE_DIR="${PREFIX}/include/boost" \
    -DBoost_LIBRARY_DIR="${PREFIX}/lib" \
    -DPython_ROOT_DIR="${PREFIX}" \
    -DPython_EXECUTABLE="${PYTHON}" \
    -DENABLE_GUI=OFF \
    -DENABLE_GFX=OFF \
    -DENABLE_INFO=OFF \
    -DUSE_RPATH=ON \
    -DCMAKE_VERBOSE_MAKEFILE=ON

make VERBOSE=1 -j"${CPU_COUNT}"

wget https://files.wwpdb.org/pub/pdb/data/monomers/components.cif.gz
stage/bin/chemdict_tool create components.cif.gz compounds.chemlib pdb -i
stage/bin/chemdict_tool update ../modules/conop/data/charmm.cif compounds.chemlib charmm

cmake .. \
    ${CMAKE_ARGS} \
    -DCMAKE_PREFIX_PATH="${PREFIX}" \
    -DCMAKE_CXX_COMPILER="${CXX}" \
    -DCXX_FLAGS="${CXXFLAGS}" \
    -DCMAKE_CXX_STANDARD=17 \
    -DBOOST_ROOT="${PREFIX}" \
    -DBoost_INCLUDE_DIR="${PREFIX}/include/boost" \
    -DBoost_LIBRARY_DIR="${PREFIX}/lib" \
    -DPython_ROOT_DIR="${PREFIX}" \
    -DPython_EXECUTABLE="${PYTHON}" \
    -DCOMPOUND_LIB="${SRC_DIR}/build/compounds.chemlib" \
    -DPARASAIL_INCLUDE_DIR="${PREFIX}/include" \
    -DPARASAIL_LIBRARY="${PREFIX}/lib/libparasail${SHLIB_EXT}" \
    -DUSE_RPATH=ON \
    -DOPTIMIZE=ON \
    -DENABLE_PARASAIL=ON \
    -DCOMPILE_TMTOOLS=ON \
    -DENABLE_GFX=ON \
    -DENABLE_GUI=ON \
    -DENABLE_INFO=ON \
    -DUSE_SHADER=ON \
    -DUSE_DOUBLE_PRECISION=OFF \
    -DENABLE_MM=ON \
    -DOPEN_MM_LIBRARY="${PREFIX}/lib/libOpenMM${SHLIB_EXT}" \
    -DOPEN_MM_INCLUDE_DIR="${PREFIX}/include" \
    -DOPEN_MM_PLUGIN_DIR="${PREFIX}/lib/plugins" \
    -DCMAKE_VERBOSE_MAKEFILE=ON

make VERBOSE=1 -j"${CPU_COUNT}"

# GFX-related tests time out for CI checks on linux-aarch64
if [[ "${build_platform}" != "linux-aarch64" ]]; then
    make check
fi

make install
