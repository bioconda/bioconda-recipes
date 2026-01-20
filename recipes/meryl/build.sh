#!/bin/bash

set -xe

ARCH_BUILD="-m64 -msse4.1"
case $(uname -m) in
    arm64|aarch64) ARCH_BUILD="" ;;
esac

make -C src BUILD_DIR="$(pwd)" \
	TARGET_DIR="${PREFIX}" \
	CXX="${CXX}" \
	CXXFLAGS="${CXXFLAGS} -O3 -Wno-c++20-extensions -Wno-inline-namespace-reopened-noninline -Wno-format ${ARCH_BUILD} -I${PREFIX}/include" \
	LDFLAGS="${LDFLAGS} -fopenmp -L${PREFIX}/lib" -j"${CPU_COUNT}"
