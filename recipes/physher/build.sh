#!/bin/bash

set -xe

case $(uname -m) in
    aarch64)
        ARCH_OPTS="-DUSE_SSE_SUPPORT=OFF"
        ;;
    *)
        ARCH_OPTS=""
        ;;
esac

cmake -S . -B build -DBUILD_CPP_WRAPPER=on -DCMAKE_INSTALL_PREFIX=$PREFIX ${ARCH_OPTS}

cmake --build build/ --target install -j ${CPU_COUNT}