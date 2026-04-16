#!/usr/bin/env bash
set -euo pipefail
TMPDIR="$(mktemp -d)"
mkdir -p "${TMPDIR}"
env -C "${TMPDIR}" cmake \
    -Wdev -Wdeprecated --warn-uninitialized \
    -DCEU_CM_SHOULD_USE_NATIVE=OFF \
    -DCEU_CM_SHOULD_ENABLE_TEST=OFF \
    -DUSE_THREAD_PARALLEL=ASIO \
    -DUSE_RANDOM_GENERATOR=STL \
    -DUSE_MALLOC=NOP \
    -DUSE_HTSLIB=hts \
    -DUSE_LIBFMT=fmt \
    ${CMAKE_ARGS} \
    -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    -DCMAKE_INSTALL_LIBDIR=lib/art_modern/lib \
    -DCMAKE_INSTALL_INCLUDEDIR=include/art_modern/include \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    "${SRC_DIR}"
# The last 4 variables override conda's default settings
cmake --build "${TMPDIR}" --parallel "${CPU_COUNT}"
cmake --install "${TMPDIR}"
rm -fr "${TMPDIR}"
