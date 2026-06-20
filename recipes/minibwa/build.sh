#!/bin/bash

set -xe

mkdir -p "${PREFIX}/bin" "${PREFIX}/lib" "${PREFIX}/include"

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
# LIBS is left untouched so the Makefile keeps -lpthread -lz -lm.
make \
    CC="${CC}" \
    CFLAGS="${CFLAGS}" \
    CPPFLAGS="${CPPFLAGS}" \
    LDFLAGS="${LDFLAGS}" \
    -j"${CPU_COUNT}" \
    minibwa

install -m 0755 minibwa "${PREFIX}/bin"
install -m 0644 libminibwa.a "${PREFIX}/lib"
install -m 0644 minibwa.h "${PREFIX}/include"
