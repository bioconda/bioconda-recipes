#!/bin/bash

set -euo pipefail

export CXXFLAGS="${CXXFLAGS} -I${PREFIX}/include -O3"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

mkdir -p "${PREFIX}/share/rDock"
cp -rf lib data tests "${PREFIX}/share/rDock"
rm -f lib/*
make CXX="${CXX}" CXX_EXTRA_FLAGS="-I${PREFIX}/include -Wno-deprecated-declarations" PREFIX="${PREFIX}" -j"${CPU_COUNT}"
PREFIX="${PREFIX}" make install

mkdir -p "${PREFIX}/etc/conda/activate.d"
mkdir -p "${PREFIX}/etc/conda/deactivate.d"
install -m 755 "${RECIPE_DIR}/activate.sh" "${PREFIX}/etc/conda/activate.d/${PKG_NAME}_activate.sh"
install -m 755 "${RECIPE_DIR}/deactivate.sh" "${PREFIX}/etc/conda/deactivate.d/${PKG_NAME}_deactivate.sh"
install -m 755 "${RECIPE_DIR}/activate.fish" "${PREFIX}/etc/conda/activate.d/${PKG_NAME}_activate.fish"
install -m 755 "${RECIPE_DIR}/deactivate.fish" "${PREFIX}/etc/conda/deactivate.d/${PKG_NAME}_deactivate.fish"
