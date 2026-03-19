#!/bin/bash
set -xeu -o pipefail

STAGING="${SRC_DIR}/staging"
mkdir -p "${STAGING}/lib" "${STAGING}/include" "${PREFIX}/bin"

# ---------- 1. isa-l (autotools) ----------
cd "${SRC_DIR}/isa-l"
# On x86_64, nasm is the assembler; on aarch64, isa-l uses CC -D__ASSEMBLY__
if [ "$(uname -m)" = "x86_64" ]; then
    export AS=nasm
fi
./autogen.sh
./configure --prefix="${STAGING}" --enable-static --disable-shared \
    CC="${CC}" CFLAGS="${CFLAGS:-}"
make -j"${CPU_COUNT}"
make install

# ---------- 2. libdeflate (cmake) ----------
cd "${SRC_DIR}/libdeflate"
cmake -B build -G Ninja \
    ${CMAKE_ARGS:-} \
    -DCMAKE_INSTALL_PREFIX="${STAGING}" \
    -DCMAKE_BUILD_TYPE=Release \
    -DLIBDEFLATE_BUILD_STATIC_LIB=ON \
    -DLIBDEFLATE_BUILD_SHARED_LIB=OFF \
    -DLIBDEFLATE_BUILD_GZIP=OFF
cmake --build build -j"${CPU_COUNT}"
cmake --install build

# ---------- 3. highway (cmake) ----------
cd "${SRC_DIR}/highway"
cmake -B build -G Ninja \
    ${CMAKE_ARGS:-} \
    -DCMAKE_INSTALL_PREFIX="${STAGING}" \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=OFF \
    -DBUILD_TESTING=OFF \
    -DHWY_ENABLE_EXAMPLES=OFF \
    -DHWY_ENABLE_INSTALL=ON
cmake --build build -j"${CPU_COUNT}"
cmake --install build

# ---------- 4. fastp ----------
# Export CXXFLAGS as env var (not make arg) so Makefile's ':= ... ${CXXFLAGS}'
# appends our flags instead of losing its own -I flags.
# Override LD_FLAGS to bypass upstream's -static on Linux (conda has no static glibc).
cd "${SRC_DIR}/fastp"
export CXXFLAGS="${CXXFLAGS} -O3 -std=c++14"
make CXX="${CXX}" \
    INCLUDE_DIRS="${STAGING}/include" \
    LIBRARY_DIRS="${STAGING}/lib" \
    LD_FLAGS="-L${STAGING}/lib ${STAGING}/lib/libisal.a ${STAGING}/lib/libdeflate.a ${STAGING}/lib/libhwy.a -lpthread" \
    -j"${CPU_COUNT}"
make install PREFIX="${PREFIX}"
