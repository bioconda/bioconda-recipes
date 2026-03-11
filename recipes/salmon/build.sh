#!/usr/bin/env bash
set -euo pipefail

BUILD_DIR="${SRC_DIR}/build"
DEPS_PREFIX="${SRC_DIR}/_deps_prefix"
THIRDPARTY_DIR="${SRC_DIR}/_thirdparty"
ZLIBNG_VERSION="2.3.3"
ZLIBNG_URL="https://github.com/zlib-ng/zlib-ng/archive/refs/tags/${ZLIBNG_VERSION}.tar.gz"
ZLIBNG_TARBALL="${THIRDPARTY_DIR}/zlib-ng-${ZLIBNG_VERSION}.tar.gz"
ZLIBNG_SRC_DIR="${THIRDPARTY_DIR}/zlib-ng-${ZLIBNG_VERSION}"

mkdir -p "${DEPS_PREFIX}" "${THIRDPARTY_DIR}"

# ---- Build zlib-ng (compat mode, static) ----
curl -L --fail "${ZLIBNG_URL}" -o "${ZLIBNG_TARBALL}"
tar -xzf "${ZLIBNG_TARBALL}" -C "${THIRDPARTY_DIR}"

cmake -S "${ZLIBNG_SRC_DIR}" -B "${ZLIBNG_SRC_DIR}/build" -G Ninja \
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

cmake --build "${ZLIBNG_SRC_DIR}/build" --parallel "${CPU_COUNT:-4}"
cmake --install "${ZLIBNG_SRC_DIR}/build"

# ---- Provide ZLIBNG package config shim for Salmon find_package(ZLIBNG) ----
ZLIBNG_CMAKE_DIR="${DEPS_PREFIX}/lib/cmake/ZLIBNG"
mkdir -p "${ZLIBNG_CMAKE_DIR}"

cat > "${ZLIBNG_CMAKE_DIR}/ZLIBNGConfig.cmake" <<'EOF'
get_filename_component(_zng_prefix "${CMAKE_CURRENT_LIST_DIR}/../../.." ABSOLUTE)

if(NOT TARGET ZLIBNG::ZLIBNG)
  add_library(ZLIBNG::ZLIBNG STATIC IMPORTED GLOBAL)
  set_target_properties(ZLIBNG::ZLIBNG PROPERTIES
    IMPORTED_LOCATION "${_zng_prefix}/lib/libz.a"
    INTERFACE_INCLUDE_DIRECTORIES "${_zng_prefix}/include"
  )
endif()

set(ZLIBNG_FOUND TRUE)
set(ZLIBNG_INCLUDE_DIR "${_zng_prefix}/include")
set(ZLIBNG_LIBRARY ZLIBNG::ZLIBNG)
EOF

# Diagnostics (keep while stabilizing recipe)
ls -la "${DEPS_PREFIX}/lib" || true
ls -la "${DEPS_PREFIX}/include" || true
ls -la "${ZLIBNG_CMAKE_DIR}" || true
ls -la "${SRC_DIR}/vendor" || true

# ---- Build Salmon ----
COMMON_ARGS=(
  -S . -B "${BUILD_DIR}" -G Ninja
  -DCMAKE_BUILD_TYPE=Release
  -DCMAKE_INSTALL_PREFIX="${PREFIX}"
  -DCMAKE_INSTALL_LIBDIR=lib
  -DCMAKE_PREFIX_PATH="${DEPS_PREFIX};${PREFIX}"
  -DZLIBNG_DIR="${ZLIBNG_CMAKE_DIR}"
  -DSALMON_ENABLE_TESTS=OFF
  -DSALMON_USE_SYSTEM_DEPS=ON
  -DSALMON_FETCH_MISSING_DEPS=OFF
  -DSALMON_USE_ZLIB_NG=REQUIRED
  -DSALMON_USE_HTSLIB=REQUIRED
  -DSALMON_USE_MIMALLOC=AUTO
  -DSALMON_PUFFERFISH_SOURCE_DIR="${SRC_DIR}/vendor/pufferfish"
  -DSALMON_FQFEEDER_SOURCE_DIR="${SRC_DIR}/vendor/FQFeeder"
  -DFETCHCONTENT_SOURCE_DIR_SALMON_LIBGFF="${SRC_DIR}/vendor/libgff"
)

if [[ "$(uname)" == "Linux" ]]; then
  COMMON_ARGS+=(
    -DSALMON_BOOST_USE_STATIC_LIBS=ON
    -DBUILD_SHARED_LIBS=OFF
    -DCMAKE_FIND_LIBRARY_SUFFIXES=".a"
  )
else
  COMMON_ARGS+=(-DSALMON_BOOST_USE_STATIC_LIBS=OFF)
fi

cmake "${COMMON_ARGS[@]}"
cmake --build "${BUILD_DIR}" --parallel "${CPU_COUNT:-4}"
cmake --install "${BUILD_DIR}"
