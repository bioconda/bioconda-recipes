#!/bin/bash
set -ex

## Using Ninja instead of Make
export CMAKE_GENERATOR="Ninja"
export CMAKE_FIND_PACKAGE_PREFER_CONFIG=ON

## 1) Build CM-Rep code (C++)
mkdir -p "${SRC_DIR}/build"
cd "${SRC_DIR}/build"

cmake -S "${SRC_DIR}" -B "${SRC_DIR}/build" \
    -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_CXX_STANDARD=17 \
    -DCMAKE_PREFIX_PATH="${PREFIX}" \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DCMAKE_INSTALL_RPATH='$ORIGIN/../lib' \
    -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON

cmake --build . --target install -- -j${CPU_COUNT}

## 2) Install MeTA package
cd "${SRC_DIR}"
${PYTHON} -m pip install . --no-deps -vv

## 3) Copy example data for testing:
mkdir -p "${PREFIX}/share/meta-neuro/example"
cp "${SRC_DIR}/resources/test.nii.gz" "${PREFIX}/share/meta-neuro/example/"
