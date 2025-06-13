#!/bin/bash
set -euo pipefail

export CXXFLAGS="${CXXFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

if [[ 'uname -s' == "Darwin" ]]; then
    export CXXFLAGS="${CXXFLAGS} -I${BUILD_PREFIX}/lib/clang/20/include"
fi

install -d ${PREFIX}/share/rDock
cp -rf lib data tests ${PREFIX}/share/rDock
rm -f lib/*
make CXX="${CXX}" CXX_EXTRA_FLAGS="-I${PREFIX}/include -Wno-deprecated-declarations" PREFIX="${PREFIX}" -j"${CPU_COUNT}"
PREFIX="${PREFIX}" make install

mkdir -p ${PREFIX}/etc/conda/activate.d
mkdir -p ${PREFIX}/etc/conda/deactivate.d
cp -f ${RECIPE_DIR}/activate.sh "${PREFIX}/etc/conda/activate.d/activate.sh"
cp -f ${RECIPE_DIR}/deactivate.sh "${PREFIX}/etc/conda/deactivate.d/deactivate.sh"
