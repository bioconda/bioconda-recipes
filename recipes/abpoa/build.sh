#!/bin/bash

mkdir -p ${PREFIX}/bin

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="-Wall -O3 -Wno-unused-variable -Wno-unused-function -Wno-misleading-indentation -DUSE_SIMDE -DSIMDE_ENABLE_NATIVE_ALIASES -I${PREFIX}/include -L${PREFIX}/lib"

OS=$(uname -s)
ARCH=$(uname -m)

# ARCH_BUILD=""
# case $(uname -m) in
# 	arm64) ARCH_BUILD="armv8=1" ;;
# 	aarch64) ARCH_BUILD="aarch64=1" ;;
# esac

make CC="${CC}" \
	CFLAGS="${CFLAGS}" INCLUDE="-I${PREFIX}/include" \
	PREFIX="${PREFIX}" -j"${CPU_COUNT}"
