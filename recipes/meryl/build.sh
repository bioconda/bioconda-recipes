#!/bin/bash

set -xe

ARCH_BUILD="-m64 -msse4.1"
case $(uname -m) in
    arm64|aarch64)
        ARCH_BUILD=""
        # bioconda's aarch64 sysroot glibc is older than 2.28, so <sys/auxv.h>
        # does not define HWCAP_ASIMD. htscodecs' rANS_static4x16pr.c needs it
        # for NEON runtime detection. Provide the well-known constant
        # (HWCAP_ASIMD = 1 << 1) from Linux's arch/arm64/include/uapi/asm/hwcap.h.
        # meryl's Makefile appends env CFLAGS to its own defaults, so this
        # reaches every C compile.
        export CFLAGS="${CFLAGS:-} -DHWCAP_ASIMD=2"
        ;;
esac

make -C src BUILD_DIR="$(pwd)" \
	TARGET_DIR="${PREFIX}" \
	CXX="${CXX}" \
	CXXFLAGS="${CXXFLAGS} -pthread -fopenmp -std=c++20 -O3 -Wno-c++20-extensions -Wno-inline-namespace-reopened-noninline -Wno-format ${ARCH_BUILD} -I${PREFIX}/include" \
	LDFLAGS="${LDFLAGS} -fopenmp -L${PREFIX}/lib" -j"${CPU_COUNT}"
