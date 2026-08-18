#!/bin/bash
# Adapted from the `cfm` (v33) recipe's build.sh. The environment exports, the
# INCHI-API header shuffle and the cmake -D flags are all carried over: they
# encode how CFM's CMake expects to find RDKit, LPSolve, Boost and LBFGS inside
# a conda prefix, and none of that is discoverable from the upstream docs.
set -euo pipefail

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
# macOS ignores LD_LIBRARY_PATH; the equivalent there is DYLD_LIBRARY_PATH.
if [[ "$(uname -s)" == "Darwin" ]]; then
    export DYLD_LIBRARY_PATH="${PREFIX}/lib"
else
    export LD_LIBRARY_PATH="${PREFIX}/lib"
fi
export LDFLAGS="-L${PREFIX}/lib"
export CPPFLAGS="-I${PREFIX}/include"

# CFM includes <INCHI-API/inchi.h> from RDKit's External tree, but conda's rdkit
# does not install the header at that path. INSTALL.md documents the same copy
# for source installs, and the `cfm` v33 recipe hard-codes GraphMol/inchi.h.
#
# That hard-coded path is not safe to assume across rdkit generations, so locate
# the header instead and fail loudly with a useful message if it is genuinely
# absent -- CFM cannot build without INCHI support, so continuing would only
# produce a more confusing error later.
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

# CMakeLists.txt lives in cfm/, not at the archive root: the Bitbucket archive
# also carries the model directories and the docker/ build definitions.
cd cfm

mkdir -p build
cd build

# INCLUDE_TRAIN=OFF is deliberate. CMakeLists.txt:121 requires MPI only when
# INCLUDE_TRAIN or INCLUDE_TESTS is on ("Building the training code requires
# extra dependencies, e.g. MPI"). With training on, CMake's MPI probe fails
# under the sysroot that {{ stdlib('c') }} introduces:
#     -- Could NOT find MPI_C (missing: MPI_C_WORKS)
# and adding mpich to build: as well as host: did not fix it.
#
# The Galaxy wrapper uses cfm-id only, so the training binaries are out of
# scope. Turning them off drops the MPI dependency entirely. NOTE this is a
# deliberate difference from the older `cfm` v33 package, which does ship
# cfm-train. If cfm-train is ever needed here, the MPI probe has to be solved
# first.
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

# Install the pretrained CFM-ID 4 parameters so the tools have models to use.
# cfm-cross-validation-models/ (~172 MB) is deliberately NOT installed: it is
# 92% of the source archive and is only needed to reproduce the paper's
# cross-validation, not to run predictions or identifications.
cd "${SRC_DIR}"
modeldir="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}"
mkdir -p "${modeldir}"
cp -rp cfm-pretrained-models/* "${modeldir}/"

echo "Installed CFM-ID binaries:"
ls -1 "${PREFIX}/bin" | grep -E '^(cfm|fraggraph)' || true
echo "Installed models under ${modeldir}:"
ls -1 "${modeldir}"
