#!/bin/bash

ARCH_BUILD=""
case $(uname -m) in
    x86_64) ARCH_BUILD="-DHAVE_SSE4_1=1" ;;
esac

if [ -z "${ARCH_BUILD}" ]; then
    echo "Unsupported architecture"
    exit 1
fi

mkdir build
cd build

cmake -DCMAKE_INSTALL_PREFIX="${PREFIX}" -DHAVE_TESTS=0 -DHAVE_MPI=0 ${ARCH_BUILD} -DVERSION_OVERRIDE="${PKG_VERSION}" ..

make -j${CPU_COUNT} ${VERBOSE_CM}
make install
