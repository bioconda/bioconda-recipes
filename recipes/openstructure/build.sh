#!/usr/bin/env bash

set -euxo pipefail

mkdir -p build && cd build

PYVER=$($PYTHON -c 'import sys; print(f"{sys.version_info[0]}.{sys.version_info[1]}")')

cmake .. \
    -DCMAKE_CXX_STANDARD=17 \
    -DCMAKE_PREFIX_PATH=${PREFIX} \
    -DBOOST_ROOT=${PREFIX} \
    -DENABLE_GUI=OFF \
    -DENABLE_GFX=OFF \
    -DENABLE_INFO=OFF \
    -DUSE_RPATH=ON

make VERBOSE=1 -j"${CPU_COUNT}"

cp ../components/components.cif.gz .
stage/bin/chemdict_tool create components.cif.gz compounds.chemlib pdb -i
stage/bin/chemdict_tool update ../modules/conop/data/charmm.cif compounds.chemlib charmm

OMM_LIBDIR=${PREFIX}/lib/python${PYVER}/site-packages/OpenMM.libs
cmake .. \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_CXX_STANDARD=17 \
    -DCMAKE_PREFIX_PATH=${PREFIX} \
    -DBOOST_ROOT=${PREFIX} \
    -DCOMPOUND_LIB=${SRC_DIR}/build/compounds.chemlib \
    -DPARASAIL_INCLUDE_DIR=${PREFIX}/include \
    -DPARASAIL_LIBRARY=${PREFIX}/lib/libparasail.${SHLIB_EXT} \
    -DUSE_RPATH=ON \
    -DOPTIMIZE=ON \
    -DENABLE_PARASAIL=ON \
    -DCOMPILE_TMTOOLS=OFF \
    -DENABLE_GFX=ON \
    -DENABLE_GUI=ON \
    -DENABLE_INFO=ON \
    -DUSE_SHADER=ON \
    -DUSE_DOUBLE_PRECISION=OFF \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DENABLE_MM=ON \
    -DOPEN_MM_LIBRARY=${OMM_LIBDIR}/lib/libOpenMM.${SHLIB_EXT} \
    -DOPEN_MM_INCLUDE_DIR=${OMM_LIBDIR}/include \
    -DOPEN_MM_PLUGIN_DIR=${OMM_LIBDIR}/lib/plugins \

make VERBOSE=1 -j"${CPU_COUNT}"
make check
make install
