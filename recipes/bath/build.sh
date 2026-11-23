#!/bin/bash
set -euxo pipefail

# newer config.guess/config.sub (osx-arm64, aarch64)
cp -f "${BUILD_PREFIX}"/share/gnuconfig/config.* .

# Pick the vector implementation explicitly instead of letting configure probe
# the build machine, so the binary runs on any CPU of the target platform.
case "$(uname -m)" in
    x86_64)        SIMD="--enable-sse"  ;;
    aarch64|arm64) SIMD="--enable-neon" ;;
    *)             SIMD=""              ;;
esac

autoconf
./configure --prefix="${PREFIX}" ${SIMD} \
    CC="${CC}" CFLAGS="${CFLAGS} -O3" LDFLAGS="${LDFLAGS}"
make -j"${CPU_COUNT}"

# Install the BATH programs only. The top-level target would also install
# the documentation; easel's miniapps are not installed, so nothing clashes
# with the hmmer package.
mkdir -p "${PREFIX}/bin"
cd src
make install
