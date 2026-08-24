#!/bin/bash
set -euo pipefail

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
if [[ "$(uname -s)" == "Darwin" ]]; then
    export DYLD_LIBRARY_PATH="${PREFIX}/lib"
else
    export LD_LIBRARY_PATH="${PREFIX}/lib"
fi
export LDFLAGS="-L${PREFIX}/lib"
export CPPFLAGS="-I${PREFIX}/include"

inchi_dst="${PREFIX}/include/rdkit/External/INCHI-API"
mkdir -p "${inchi_dst}"
if [ -f "${inchi_dst}/inchi.h" ]; then
    echo "INCHI header already present at ${inchi_dst}/inchi.h"
else
    inchi_src="$(find "${PREFIX}/include/rdkit" -name inchi.h -print -quit 2>/dev/null || true)"
    if [ -z "${inchi_src}" ]; then
        echo "ERROR: no inchi.h found under ${PREFIX}/include/rdkit." >&2
        echo "CFM-ID requires RDKit built with INCHI support (-DRDK_BUILD_INCHI_SUPPORT=ON)." >&2
        echo "Headers present under GraphMol/:" >&2
        ls -1 "${PREFIX}/include/rdkit/GraphMol" 2>/dev/null | head -20 >&2
        exit 1
    fi
    echo "Found INCHI header at ${inchi_src}; copying to ${inchi_dst}/"
    cp "${inchi_src}" "${inchi_dst}/"
fi

cd cfm

mkdir -p build
cd build

cmake .. \
    -DCMAKE_CXX_STANDARD=17 \
    -DCFM_OUTPUT_DIR="${PREFIX}/bin/" \
    -DLPSOLVE_INCLUDE_DIR="${PREFIX}/include/lpsolve" \
    -DLPSOLVE_LIBRARY_DIR="${PREFIX}/lib" \
    -DBoost_INCLUDE_DIR="${PREFIX}/include" \
    -DBOOST_LIBRARYDIR="${PREFIX}/lib" \
    -DRDKIT_INCLUDE_DIR="${PREFIX}/include/rdkit" \
    -DRDKIT_INCLUDE_EXT_DIR="${PREFIX}/include/rdkit/External" \
    -DLBFGS_INCLUDE_DIR="${PREFIX}/include" \
    -DLBFGS_LIBRARY_DIR="${PREFIX}/lib" \
    -DCMAKE_BUILD_TYPE=Release \
    -DINCLUDE_TESTS=OFF \
    -DINCLUDE_TRAIN=OFF

make -j"${CPU_COUNT}" VERBOSE=1
make install VERBOSE=1

cd "${SRC_DIR}"
modeldir="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}"
mkdir -p "${modeldir}"
cp -rp cfm-pretrained-models/* "${modeldir}/"

echo "Installed CFM-ID binaries:"
ls -1 "${PREFIX}/bin" | grep -E '^(cfm|fraggraph)' || true
echo "Installed models under ${modeldir}:"
ls -1 "${modeldir}"
