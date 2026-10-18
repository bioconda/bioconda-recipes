#!/bin/bash

ARCH_BUILD=""
case $(uname -m) in
    x86_64) ARCH_BUILD="-DHAVE_SSE4_1=1" ;;
    arm64|aarch64) ARCH_BUILD="-DHAVE_ARM8=1" ;;
esac

if [ -z "${ARCH_BUILD}" ]; then
    echo "Invalid architecture"
    exit 1
fi

mkdir build
cd build || exit 1
# ProstT5 is opt-in in FoldMason 4; retain the CPU support shipped in earlier builds.
cmake -DCMAKE_INSTALL_PREFIX="${PREFIX}" -DHAVE_TESTS=0 -DHAVE_MPI=0 ${ARCH_BUILD} \
    -DENABLE_PROSTT5=1 -DENABLE_CUDA=0 -DVERSION_OVERRIDE="${PKG_VERSION}" ..
make -j${CPU_COUNT} ${VERBOSE_CM}
make install
