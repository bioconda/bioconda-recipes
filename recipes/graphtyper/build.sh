#!/usr/bin/env bash

set -xe

case $(uname -m) in
    aarch64)
        ARCH_OPTS="-Dpaw_BUILD_FLAGS=-DCMAKE_CXX_FLAGS_ARCH="
        ;;
    *)
        ARCH_OPTS=
        ;;
esac

# Generate build
mkdir -p build
cd build
cmake -DCFLAGS="${CFLAGS}" -DLDFLAGS="${LDFLAGS}" ${ARCH_OPTS} ..

# Build
VERBOSE=1 make -j ${CPU_COUNT} graphtyper

# Install
mkdir -p $PREFIX/bin
cp bin/graphtyper $PREFIX/bin/graphtyper
