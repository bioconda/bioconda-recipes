#!/bin/bash

# Add the library path to the LD_LIBRARY_PATH
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CONDA_PREFIX="${PREFIX}"

# Create the src directory
mkdir -p "${PREFIX}"/src

sed -i.bak 's|find_packages|find_namespace_packages|' setup.py
sed -i.bak 's|-std=c++11|-std=c++14|' setup.py
rm -f *.bak

# Upstream's committed version.h is stale (v1.4.0-5-g9e0d2c4); regenerate it for this release
printf '#pragma once\n#define VERSION "v%s"\n' "${PKG_VERSION}" > "${SRC_DIR}/include/version.h"

# Build the C++ library
make CXX="${CXX}" -j"${CPU_COUNT}"

# 1. Generate the SWIG wrapper BEFORE setup.py runs (setup.py globs src/*.cpp at import)
swig -c++ -python -outdir "${SRC_DIR}/lib" -I"${SRC_DIR}/include" -I"${PREFIX}/include" \
     -o "${SRC_DIR}/src/lrst_wrap.cpp" "${SRC_DIR}/src/lrst.i"
test -s "${SRC_DIR}/src/lrst_wrap.cpp"

# 2. Build the extension. setup.py hard-codes script_args=['build_ext','--build-lib','lib'],
#    so any CLI args (e.g. "install") are ignored; pass include/lib paths via env instead.
# Generate the shared library
CPPFLAGS="${CPPFLAGS}" LDFLAGS="${LDFLAGS}" ${PYTHON} setup.py

# 3. Guard: the extension must export the SWIG init function (nm -g works on Linux and macOS)
so=$(ls "${SRC_DIR}"/lib/_lrst*.so)
nm -g "${so}" | grep -q 'PyInit__lrst' || { echo "ERROR: PyInit__lrst missing from ${so}"; exit 1; }

# 4. Install: SWIG module into site-packages, CLI scripts into bin
# Copy source files to the bin directory
install -v -m 0755 "${SRC_DIR}"/lib/lrst.py "${so}" "${SP_DIR}"
install -v -m 0755 "${SRC_DIR}"/src/*.py "${PREFIX}/bin"

# Copy the SWIG generated library to the lib directory
install -v -m 0755 "${SRC_DIR}"/lib/*.py "${PREFIX}/lib"
cp -rf "${SRC_DIR}"/lib/*.so "${PREFIX}"/lib
