#!/bin/bash

set -xe

mkdir -p "${PREFIX}/bin" "${PREFIX}/lib" "${PREFIX}/include"

# Build the vendored zlib-ng (fetched as the `_zlib_ng` source) in ZLIB_COMPAT
# mode: a static, drop-in libz.a + zlib.h with a faster inflate. Static so the
# speedup is baked in without adding a runtime dependency or a track_features
# anchor.
DEPS="${SRC_DIR}/_deps"
mkdir -p "${DEPS}"
cmake -S "${SRC_DIR}/_zlib_ng" -B "${SRC_DIR}/_zlib_ng/build" -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${DEPS}" \
    -DZLIB_COMPAT=ON \
    -DBUILD_SHARED_LIBS=OFF \
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
    -DZLIB_ENABLE_TESTS=OFF \
    -DWITH_GTEST=OFF
cmake --build "${SRC_DIR}/_zlib_ng/build" --parallel "${CPU_COUNT}"
cmake --install "${SRC_DIR}/_zlib_ng/build"

# zlib-ng may install into lib or lib64 depending on the platform.
ZLIBNG_LIBDIR="${DEPS}/lib"
[ -f "${DEPS}/lib64/libz.a" ] && ZLIBNG_LIBDIR="${DEPS}/lib64"

# The bundled SSE->NEON shim (s2n-lite.h) reinterprets uint32x4_t results
# through signed int32x4_t intrinsics, which GCC on aarch64 rejects. Permit
# the conversion as GCC itself suggests (clang/macOS already accepts it).
case "$(uname -m)" in
    aarch64 | arm64)
        export CFLAGS="${CFLAGS} -flax-vector-conversions"
        ;;
esac

# CC drives the Makefile's OpenMP auto-detection. The override-makefile.patch
# lets the Makefile append its OpenMP/GPL/SSE4.2 flags on top of conda's
# CFLAGS/CPPFLAGS rather than having them clobbered by the command line.
# CPPFLAGS points at the vendored zlib.h; LIBS replaces the Makefile's `-lz`
# with the static zlib-ng archive so minibwa embeds the compat build rather
# than linking the shared system zlib.
export CPPFLAGS="-I${DEPS}/include ${CPPFLAGS}"
make \
    CC="${CC}" \
    CFLAGS="${CFLAGS}" \
    CPPFLAGS="${CPPFLAGS}" \
    LDFLAGS="${LDFLAGS}" \
    LIBS="-lpthread ${ZLIBNG_LIBDIR}/libz.a -lm" \
    -j"${CPU_COUNT}" \
    minibwa

install -m 0755 minibwa "${PREFIX}/bin"
install -m 0644 libminibwa.a "${PREFIX}/lib"
install -m 0644 minibwa.h "${PREFIX}/include"
