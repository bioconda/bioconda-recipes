#!/bin/bash

ARCH_BUILD=""
case $(uname -m) in
    x86_64) ARCH_BUILD="-DHAVE_AVX2=1" ;;
    arm64|aarch64) ARCH_BUILD="-DHAVE_ARM8=1" ;;
esac

CUDA=0
case $(uname -s) in
    Linux) CUDA=1 ;;
    Darwin) CUDA=0 ;;
esac

if [ -z "${ARCH_BUILD}" ]; then
    echo "Invalid architecture"
    exit 1
fi

mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX="${PREFIX}" -DHAVE_TESTS=0 -DHAVE_MPI=0 ${ARCH_BUILD} -DVERSION_OVERRIDE="${PKG_VERSION}" \
    -DCMAKE_CUDA_ARCHITECTURES="75-real;80-real;86-real;89-real;90" -DENABLE_CUDA=${CUDA} ..
make -j${CPU_COUNT} ${VERBOSE_CM}
make install
