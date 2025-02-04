#!/bin/bash

export CFLAGS="${CFLAGS} -O3"
export CXXFLAGS="${CXXFLAGS} -O3 -I${PREFIX}/include -Wno-stringop-overflow="
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export LC_ALL=en_US.UTF-8

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

if [[ -z "${ARCH_BUILD}" ]]; then
    echo "Invalid architecture"
    exit 1
fi

if [[ `uname` == "Darwin" ]]; then
    export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
    export CONFIG_ARGS=""
fi

cmake -S . -B build -DCMAKE_INSTALL_PREFIX="${PREFIX}" -DCMAKE_BUILD_TYPE=Release \
    -DHAVE_TESTS=0 -DHAVE_MPI=0 "${ARCH_BUILD}" -DVERSION_OVERRIDE="${PKG_VERSION}" \
    -DCMAKE_CUDA_ARCHITECTURES="75-real;80-real;86-real;89-real;90" -DENABLE_CUDA="${CUDA}" \
    -DCMAKE_CXX_COMPILER="${CXX}" -DCMAKE_CXX_FLAGS="${CXXFLAGS}" -DCMAKE_C_COMPILER="${CC}" \
    -DCMAKE_C_FLAGS="${CFLAGS}" "${CONFIG_ARGS}"
cmake --build build --target install -j "${CPU_COUNT}" "${VERBOSE_CM}"
