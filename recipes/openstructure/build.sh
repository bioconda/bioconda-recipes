#!/usr/bin/env bash

set -exuo pipefail

extra_cmake_args=
if [[ "$(uname)" == "Linux" ]]; then
    export LDFLAGS="${LDFLAGS} -Wl,--allow-shlib-undefined,--export-dynamic"
elif [[ "$(uname)" == "Darwin" ]]; then
    extra_cmake_args="-DCMAKE_OSX_SYSROOT=${CONDA_BUILD_SYSROOT}"
    export LDFLAGS="${LDFLAGS} -undefined dynamic_lookup -Wl,-export_dynamic -framework OpenGL"
fi

mkdir -p build && cd build

cmake .. \
    ${CMAKE_ARGS} \
    -DCMAKE_PREFIX_PATH="${PREFIX}" \
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
    -DCMAKE_VERBOSE_MAKEFILE=ON \
    ${extra_cmake_args}

make VERBOSE=1 -j"${CPU_COUNT}"

cp ../monomers/components.cif.gz .
stage/bin/chemdict_tool create components.cif.gz compounds.chemlib pdb -i
stage/bin/chemdict_tool update ../modules/conop/data/charmm.cif compounds.chemlib charmm

# Fix RPATH to contain parasail library
LIB_DIR="${PREFIX}/lib"
LIBPARASAIL_DIR="${SP_DIR}/parasail"
sed -i.bak \
    "s|CMAKE_INSTALL_RPATH \"\$ORIGIN/../\${LIB_DIR}\"|CMAKE_INSTALL_RPATH ${LIB_DIR};${LIBPARASAIL_DIR}|g" \
    "${SRC_DIR}/CMakeLists.txt"

cmake .. \
    ${CMAKE_ARGS} \
    -DCMAKE_PREFIX_PATH="${PREFIX}" \
    -DCXX_FLAGS="${CXXFLAGS}" \
    -DCMAKE_CXX_STANDARD=17 \
    -DBOOST_ROOT="${PREFIX}" \
    -DBoost_INCLUDE_DIR="${PREFIX}/include/boost" \
    -DBoost_LIBRARY_DIR="${PREFIX}/lib" \
    -DPython_ROOT_DIR="${PREFIX}" \
    -DPython_EXECUTABLE="${PYTHON}" \
    -DCOMPOUND_LIB="${SRC_DIR}/build/compounds.chemlib" \
    -DPARASAIL_INCLUDE_DIR="${SP_DIR}/parasail/include" \
    -DPARASAIL_LIBRARY="${SP_DIR}/parasail/libparasail${SHLIB_EXT}" \
    -DUSE_RPATH=ON \
    -DOPTIMIZE=ON \
    -DENABLE_PARASAIL=OFF \
    -DCOMPILE_TMTOOLS=OFF \
    -DENABLE_GFX=ON \
    -DENABLE_GUI=ON \
    -DENABLE_INFO=ON \
    -DUSE_SHADER=ON \
    -DUSE_DOUBLE_PRECISION=OFF \
    -DENABLE_MM=ON \
    -DOPEN_MM_LIBRARY="${PREFIX}/lib/libOpenMM${SHLIB_EXT}" \
    -DOPEN_MM_INCLUDE_DIR="${PREFIX}/include" \
    -DOPEN_MM_PLUGIN_DIR="${PREFIX}/lib/plugins" \
    -DCMAKE_VERBOSE_MAKEFILE=ON \
    ${extra_cmake_args}

make VERBOSE=1 -j"${CPU_COUNT}"
make install
