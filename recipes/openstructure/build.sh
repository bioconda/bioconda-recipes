#!/usr/bin/env bash

set -exo pipefail

# Prevent build failures due to insufficient memory in the CI environment
# Use parallel build because of serial build on osx-arm64 causing occasional errors
if [[ "${build_platform}" == "linux-aarch64" || "${build_platform}" == "osx-arm64" ]]; then
  export CPU_COUNT=$(( CPU_COUNT * 70 / 100 ))
fi

if [[ "${target_platform}" == "linux-"* ]]; then
    export LDFLAGS="${LDFLAGS} -Wl,--allow-shlib-undefined,--export-dynamic"
elif [[ "${target_platform}" == "osx-"* ]]; then
    export LDFLAGS="${LDFLAGS} -undefined dynamic_lookup -Wl,-export_dynamic -framework OpenGL"
fi

if [[ "${target_platform}" == osx-64 ]]; then
  export FFLAGS="-m64 -fPIC"
  export FCFLAGS="-m64 -fPIC"
fi

# Headless on linux-aarch64 (no Qt/OpenGL) to stay within CircleCI's 1h timeout.
# ENABLE_INFO must be OFF to drop Qt (Qt5Xml); that also forces GFX/GUI off.
if [[ "${target_platform}" == "linux-aarch64" ]]; then
  OST_ENABLE_GUI=OFF
  OST_ENABLE_GFX=OFF
  OST_ENABLE_INFO=OFF
  OST_USE_SHADER=OFF
else
  OST_ENABLE_GUI=ON
  OST_ENABLE_GFX=ON
  OST_ENABLE_INFO=ON
  OST_USE_SHADER=ON
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
    -DPARASAIL_INCLUDE_DIR="${PREFIX}/include" \
    -DPARASAIL_LIBRARY="${PREFIX}/lib/libparasail${SHLIB_EXT}" \
    -DUSE_RPATH=ON \
    -DOPTIMIZE=ON \
    -DENABLE_PARASAIL=ON \
    -DCOMPILE_TMTOOLS=ON \
    -DENABLE_GFX="${OST_ENABLE_GFX}" \
    -DENABLE_GUI="${OST_ENABLE_GUI}" \
    -DENABLE_INFO="${OST_ENABLE_INFO}" \
    -DUSE_SHADER="${OST_USE_SHADER}" \
    -DUSE_DOUBLE_PRECISION=OFF \
    -DENABLE_MM=ON \
    -DOPEN_MM_LIBRARY="${PREFIX}/lib/libOpenMM${SHLIB_EXT}" \
    -DOPEN_MM_INCLUDE_DIR="${PREFIX}/include" \
    -DOPEN_MM_PLUGIN_DIR="${PREFIX}/lib/plugins"

make -j"${CPU_COUNT}"

wget https://files.wwpdb.org/pub/pdb/data/monomers/components.cif.gz
stage/bin/chemdict_tool create components.cif.gz compounds.chemlib pdb -i
stage/bin/chemdict_tool update ../modules/conop/data/charmm.cif compounds.chemlib charmm

cmake .. -DCOMPOUND_LIB="${SRC_DIR}/build/compounds.chemlib"

make -j"${CPU_COUNT}"

make check

make install
cd "${SRC_DIR}" && rm -rf build
