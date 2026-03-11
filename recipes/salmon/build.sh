#!/usr/bin/env bash
set -euo pipefail

# Paths
BUILD_DIR="${SRC_DIR}/build"
DEPS_PREFIX="${SRC_DIR}/_deps_prefix"
ZLIBNG_VERSION="2.3.3"
ZLIBNG_TARBALL="zlib-ng-${ZLIBNG_VERSION}.tar.gz"
ZLIBNG_URL="https://github.com/zlib-ng/zlib-ng/archive/refs/tags/${ZLIBNG_VERSION}.tar.gz"

mkdir -p "${DEPS_PREFIX}" "${SRC_DIR}/_thirdparty"
cd "${SRC_DIR}/_thirdparty"

# --- Build zlib-ng v2.3.3 in zlib compatibility mode ---
curl -L --fail -o "${ZLIBNG_TARBALL}" "${ZLIBNG_URL}"
tar -xzf "${ZLIBNG_TARBALL}"
cd "zlib-ng-${ZLIBNG_VERSION}"

cmake -S . -B build -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="${DEPS_PREFIX}" \
  -DZLIB_COMPAT=ON \
  -DBUILD_SHARED_LIBS=OFF \
  -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
  -DZLIB_ENABLE_TESTS=OFF \
  -DWITH_GTEST=OFF \
  -DWITH_FUZZERS=OFF \
  -DWITH_BENCHMARKS=OFF \
  -DWITH_BENCHMARK_APPS=OFF

cmake --build build --parallel "${CPU_COUNT:-4}"
cmake --install build

# Ensure CMake/pkg-config resolve our zlib-ng first
export CMAKE_PREFIX_PATH="${DEPS_PREFIX};${PREFIX}"
export CMAKE_LIBRARY_PATH="${DEPS_PREFIX}/lib;${PREFIX}/lib"
export CMAKE_INCLUDE_PATH="${DEPS_PREFIX}/include;${PREFIX}/include"
export PKG_CONFIG_PATH="${DEPS_PREFIX}/lib/pkgconfig:${PREFIX}/lib/pkgconfig:${PKG_CONFIG_PATH:-}"

cd "${SRC_DIR}"

# --- Build Salmon ---
cmake -S . -B "${BUILD_DIR}" -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DSALMON_ENABLE_TESTS=OFF \
  -DSALMON_USE_SYSTEM_DEPS=ON \
  -DSALMON_FETCH_MISSING_DEPS=OFF \
  -DSALMON_USE_ZLIB_NG=REQUIRED \
  -DSALMON_USE_HTSLIB=REQUIRED \
  -DSALMON_USE_MIMALLOC=AUTO \
  -DSALMON_PUFFERFISH_SOURCE_DIR="${SRC_DIR}/vendor/pufferfish" \
  -DSALMON_FQFEEDER_SOURCE_DIR="${SRC_DIR}/vendor/FQFeeder" \
  -DFETCHCONTENT_SOURCE_DIR_SALMON_LIBGFF="${SRC_DIR}/vendor/libgff"

# Optional: Linux static-leaning; avoid on macOS
if [[ "$(uname)" == "Linux" ]]; then
  cmake -S . -B "${BUILD_DIR}" -G Ninja \
    -DSALMON_BOOST_USE_STATIC_LIBS=ON \
    -DBUILD_SHARED_LIBS=OFF \
    -DCMAKE_FIND_LIBRARY_SUFFIXES=".a"
fi

cmake --build "${BUILD_DIR}" --parallel "${CPU_COUNT:-4}"
cmake --install "${BUILD_DIR}"
