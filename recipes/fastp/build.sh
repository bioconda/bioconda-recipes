#!/bin/bash
set -xeu -o pipefail

STAGING="${SRC_DIR}/staging"
mkdir -p "${STAGING}/lib" "${STAGING}/include" "${PREFIX}/bin"

# ---------- 1. isa-l (autotools) ----------
cd "${SRC_DIR}/isa-l"
./autogen.sh
./configure --prefix="${STAGING}" --enable-static --disable-shared
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

# ---------- 4. zstd (make) ----------
cd "${SRC_DIR}/zstd"
make -j"${CPU_COUNT}" lib-release
cp lib/libzstd.a "${STAGING}/lib/"
cp lib/zstd.h lib/zstd_errors.h lib/zdict.h "${STAGING}/include/"

# ---------- 5. fastp ----------
cd "${SRC_DIR}/fastp"
make CXX="${CXX}" \
    CXXFLAGS="${CXXFLAGS} -O3 -std=c++14" \
    INCLUDE_DIRS="${STAGING}/include" \
    LIBRARY_DIRS="${STAGING}/lib" \
    -j"${CPU_COUNT}"
make install PREFIX="${PREFIX}"
