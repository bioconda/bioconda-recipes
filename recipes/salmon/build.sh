#!/usr/bin/env bash
set -euo pipefail

extra_cmake_args=(
  -DCMAKE_BUILD_TYPE=Release
  -DCMAKE_INSTALL_PREFIX="${PREFIX}"
  -DCMAKE_INSTALL_LIBDIR=lib
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
  extra_cmake_args+=(
    -DSALMON_BOOST_USE_STATIC_LIBS=ON
    -DBUILD_SHARED_LIBS=OFF
    -DCMAKE_FIND_LIBRARY_SUFFIXES=".a"
  )
else
  # macOS: allow shared deps from conda-forge
  extra_cmake_args+=(
    -DSALMON_BOOST_USE_STATIC_LIBS=OFF
  )
fi

cmake -S . -B build -G Ninja "${extra_cmake_args[@]}"
cmake --build build --parallel "${CPU_COUNT:-4}"
cmake --install build
