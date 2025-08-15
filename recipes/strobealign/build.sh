#!/usr/bin/env bash

set -xe

case $(uname -m) in
    x86_64)
        ARCH_FLAGS="-msse4.2"
        ;;
    *)
        ARCH_FLAGS=""
        ;;
esac

cmake -B build \
    -DCMAKE_C_FLAGS="${ARCH_FLAGS}" \
    -DCMAKE_CXX_FLAGS="${ARCH_FLAGS} -D_LIBCPP_DISABLE_AVAILABILITY" \
    -DCMAKE_C_STANDARD=11 \
    -DCMAKE_C_STANDARD_REQUIRED=ON \
    -DCMAKE_INSTALL_PREFIX=$PREFIX
make -j ${CPU_COUNT} -C build VERBOSE=1
make -C build install
