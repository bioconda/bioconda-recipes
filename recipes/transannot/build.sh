#!/bin/bash -e

set -xe

case $(uname -m) in
    aarch64)
        ARCH_OPTS="-DHAVE_ARM8=1"
        ;;
    *)
        ARCH_OPTS="-DHAVE_SSE4_1=1"
        ;;
esac

mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX="${PREFIX}" -DHAVE_TESTS=0 -DHAVE_MPI=0 "${ARCH_OPTS}" -DVERSION_OVERRIDE="${PKG_VERSION}" ..
make -j${CPU_COUNT} ${VERBOSE_CM}
make install
