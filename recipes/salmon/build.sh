#!/usr/bin/env bash
set -euo pipefail

BUILD_DIR="${SRC_DIR}/build"
DEPS_PREFIX="${SRC_DIR}/_deps_prefix"
THIRDPARTY_DIR="${SRC_DIR}/_thirdparty"
CMAKE_SHIM_DIR="${SRC_DIR}/_cmake_shims"

ZLIBNG_VERSION="2.3.3"
ZLIBNG_URL="https://github.com/zlib-ng/zlib-ng/archive/refs/tags/${ZLIBNG_VERSION}.tar.gz"
ZLIBNG_TARBALL="${THIRDPARTY_DIR}/zlib-ng-${ZLIBNG_VERSION}.tar.gz"
ZLIBNG_SRC_DIR="${THIRDPARTY_DIR}/zlib-ng-${ZLIBNG_VERSION}"

mkdir -p "${BUILD_DIR}" "${DEPS_PREFIX}" "${THIRDPARTY_DIR}" "${CMAKE_SHIM_DIR}"

# Build zlib-ng (compat mode)
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

# Detect libdir
if [[ -f "${DEPS_PREFIX}/lib64/libz.a" ]]; then
  ZLIB_LIBDIR="${DEPS_PREFIX}/lib64"
elif [[ -f "${DEPS_PREFIX}/lib/libz.a" ]]; then
  ZLIB_LIBDIR="${DEPS_PREFIX}/lib"
else
  echo "ERROR: libz.a not found under ${DEPS_PREFIX}/lib64 or ${DEPS_PREFIX}/lib"
  exit 1
fi

# Provide FindZLIBNG.cmake shim
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

# Diagnostics
echo "Using DEPS_PREFIX=${DEPS_PREFIX}"
echo "Using ZLIB_LIBDIR=${ZLIB_LIBDIR}"
test -f "${ZLIB_LIBDIR}/libz.a"
test -f "${CMAKE_SHIM_DIR}/FindZLIBNG.cmake"

# Build Salmon:
# - allow fetch fallback for deps/submodules (needed for pufferfish recursive submodules)
# - keep system deps ON so available conda libs are used first
cmake -S . -B "${BUILD_DIR}" -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DCMAKE_PREFIX_PATH="${DEPS_PREFIX};${PREFIX}" \
  -DCMAKE_MODULE_PATH="${CMAKE_SHIM_DIR}" \
  -DCMAKE_LIBRARY_PATH="${ZLIB_LIBDIR};${PREFIX}/lib" \
  -DCMAKE_INCLUDE_PATH="${DEPS_PREFIX}/include;${PREFIX}/include" \
  -DSALMON_ENABLE_TESTS=OFF \
  -DSALMON_USE_SYSTEM_DEPS=ON \
  -DSALMON_FETCH_MISSING_DEPS=ON \
  -DSALMON_USE_ZLIB_NG=REQUIRED \
  -DSALMON_USE_HTSLIB=REQUIRED \
  -DSALMON_BOOST_USE_STATIC_LIBS=OFF \
  -DSALMON_PUFFERFISH_GIT_REPOSITORY="https://github.com/COMBINE-lab/pufferfish.git" \
  -DSALMON_PUFFERFISH_GIT_TAG="ace68c1c022816ba8c50a1a07c5d08f2abd597d6" \
  -DSALMON_FQFEEDER_GIT_REPOSITORY="https://github.com/rob-p/FQFeeder.git" \
  -DSALMON_FQFEEDER_GIT_TAG="f5b08d1002351c192b69048ac9f6cf4c7c116265"


cmake --build "${BUILD_DIR}" --parallel "${CPU_COUNT:-4}"

## temp until 1.11.4
# libgff install-path workaround for FetchContent builds
if [[ ! -f "${BUILD_DIR}/libgff.a" ]]; then
  GFF_ARCHIVE="$(find "${BUILD_DIR}/_deps/salmon_libgff-build" -type f -name 'libgff.a' | head -n 1 || true)"
  if [[ -n "${GFF_ARCHIVE}" && -f "${GFF_ARCHIVE}" ]]; then
    cp -f "${GFF_ARCHIVE}" "${BUILD_DIR}/libgff.a"
  fi
fi

cmake --install "${BUILD_DIR}"
