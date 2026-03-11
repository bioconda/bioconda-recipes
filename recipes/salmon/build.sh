#!/usr/bin/env bash
set -euo pipefail

# -----------------------------
# Paths and versions
# -----------------------------
BUILD_DIR="${SRC_DIR}/build"
DEPS_PREFIX="${SRC_DIR}/_deps_prefix"
THIRDPARTY_DIR="${SRC_DIR}/_thirdparty"
CMAKE_SHIM_DIR="${SRC_DIR}/_cmake_shims"

ZLIBNG_VERSION="2.3.3"
ZLIBNG_URL="https://github.com/zlib-ng/zlib-ng/archive/refs/tags/${ZLIBNG_VERSION}.tar.gz"
ZLIBNG_TARBALL="${THIRDPARTY_DIR}/zlib-ng-${ZLIBNG_VERSION}.tar.gz"
ZLIBNG_SRC_DIR="${THIRDPARTY_DIR}/zlib-ng-${ZLIBNG_VERSION}"

mkdir -p "${BUILD_DIR}" "${DEPS_PREFIX}" "${THIRDPARTY_DIR}" "${CMAKE_SHIM_DIR}"

# -----------------------------
# Build zlib-ng (compat mode, static)
# -----------------------------
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

# -----------------------------
# Detect libdir layout
# -----------------------------
if [[ -f "${DEPS_PREFIX}/lib64/libz.a" ]]; then
  ZLIB_LIBDIR="${DEPS_PREFIX}/lib64"
elif [[ -f "${DEPS_PREFIX}/lib/libz.a" ]]; then
  ZLIB_LIBDIR="${DEPS_PREFIX}/lib"
else
  echo "ERROR: Could not find libz.a in ${DEPS_PREFIX}/lib64 or ${DEPS_PREFIX}/lib"
  exit 1
fi

# -----------------------------
# CMake shim: FindZLIBNG.cmake
# Maps zlib-ng compat's ZLIB package to ZLIBNG::ZLIBNG
# -----------------------------
cat > "${CMAKE_SHIM_DIR}/FindZLIBNG.cmake" <<EOF
find_package(ZLIB CONFIG REQUIRED
  PATHS "${ZLIB_LIBDIR}/cmake/ZLIB"
  NO_DEFAULT_PATH)

if(TARGET ZLIB::ZLIB AND NOT TARGET ZLIBNG::ZLIBNG)
  add_library(ZLIBNG::ZLIBNG INTERFACE IMPORTED)
  target_link_libraries(ZLIBNG::ZLIBNG INTERFACE ZLIB::ZLIB)
endif()

set(ZLIBNG_FOUND TRUE)
set(ZLIBNG_INCLUDE_DIR "${DEPS_PREFIX}/include")
set(ZLIBNG_LIBRARY ZLIBNG::ZLIBNG)
EOF

# -----------------------------
# Diagnostics
# -----------------------------
echo "Using DEPS_PREFIX=${DEPS_PREFIX}"
echo "Using ZLIB_LIBDIR=${ZLIB_LIBDIR}"
echo "Using CMAKE_SHIM_DIR=${CMAKE_SHIM_DIR}"

test -f "${ZLIB_LIBDIR}/libz.a"
test -f "${ZLIB_LIBDIR}/cmake/ZLIB/zlib-config.cmake"
test -f "${CMAKE_SHIM_DIR}/FindZLIBNG.cmake"

ls -la "${DEPS_PREFIX}" || true
ls -la "${DEPS_PREFIX}/include" || true
ls -la "${ZLIB_LIBDIR}" || true
ls -la "${ZLIB_LIBDIR}/cmake/ZLIB" || true
ls -la "${CMAKE_SHIM_DIR}" || true
ls -la "${SRC_DIR}/vendor" || true

# -----------------------------
# Build Salmon
# -----------------------------
CMAKE_ARGS=(
  -S . -B "${BUILD_DIR}" -G Ninja
  -DCMAKE_BUILD_TYPE=Release
  -DCMAKE_INSTALL_PREFIX="${PREFIX}"
  -DCMAKE_INSTALL_LIBDIR=lib
  -DCMAKE_PREFIX_PATH="${DEPS_PREFIX};${PREFIX}"
  -DCMAKE_MODULE_PATH="${CMAKE_SHIM_DIR}"
  -DCMAKE_LIBRARY_PATH="${ZLIB_LIBDIR};${PREFIX}/lib"
  -DCMAKE_INCLUDE_PATH="${DEPS_PREFIX}/include;${PREFIX}/include"

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

# Prefer static on Linux where possible; macOS usually needs shared Boost.
if [[ "$(uname)" == "Linux" ]]; then
  CMAKE_ARGS+=(
    -DSALMON_BOOST_USE_STATIC_LIBS=ON
    -DBUILD_SHARED_LIBS=OFF
    -DCMAKE_FIND_LIBRARY_SUFFIXES=".a"
  )
else
  CMAKE_ARGS+=(
    -DSALMON_BOOST_USE_STATIC_LIBS=OFF
  )
fi

cmake "${CMAKE_ARGS[@]}"
cmake --build "${BUILD_DIR}" --parallel "${CPU_COUNT:-4}"
cmake --install "${BUILD_DIR}"
