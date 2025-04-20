#!/usr/bin/env bash
set -euxo pipefail

sed -i 's|<boost/filesystem/convenience.hpp>|<boost/filesystem.hpp>|' modules/seq/alg/src/hmm_pseudo_counts.cc

# ビルド用ディレクトリ作成
mkdir build
cd build

# Python バージョン取得(<major>.<minor>)
PYVER=$($PYTHON -c 'import sys; print(f"{sys.version_info[0]}.{sys.version_info[1]}")')

cmake .. \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_BUILD_TYPE=Release \
  -DPython_EXECUTABLE=${PYTHON} \
  -DBoost_INCLUDE_DIR=${PREFIX}/include \
  -DBOOST_PYTHON_LIBRARIES=${PREFIX}/lib/libboost_python${PYVER}.so \
  -DOPTIMIZE=1 \
  -DENABLE_MM=1 \
  -DOPEN_MM_LIBRARY=${PREFIX}/lib/python${PYVER}/site-packages/OpenMM.libs/lib \
  -DOPEN_MM_INCLUDE_DIR=${PREFIX}/lib/python${PYVER}/site-packages/OpenMM.libs/include \
  -DOPEN_MM_PLUGIN_DIR=${PREFIX}/lib/python${PYVER}/site-packages/OpenMM.libs/lib/plugins \
  -DENABLE_PARASAIL=1 \
  -DCOMPILE_TMTOOLS=1 \
  -DENABLE_GFX=1 \
  -DENABLE_GUI=0 \
  -DENABLE_INFO=0 \
  -DCMAKE_VERBOSE_MAKEFILE=ON

make VERBOSE=1

cp ../components/components.cif.gz .
stage/bin/chemdict_tool create components.cif.gz compounds.chemlib pdb -i
stage/bin/chemdict_tool update ../modules/conop/data/charmm.cif compounds.chemlib charmm

cmake .. \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_BUILD_TYPE=Release \
  -DPython_EXECUTABLE=${PYTHON} \
  -DBOOST_PYTHON_LIBRARIES=${PREFIX}/lib/libboost_python${PYVER}.so \
  -DCOMPOUND_LIB=${PWD}/compounds.chemlib \
  -DCMAKE_VERBOSE_MAKEFILE=ON

make VERBOSE=1
make check
make install
