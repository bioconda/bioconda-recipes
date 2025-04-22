#!/bin/bash -eu

set -xe

OS=$(uname)
ARCH=$(uname -m)
if [[ ${OS} == "Linux" ]]; then
	export C_INCLUDE_PATH="${PREFIX}/include"
	export LIBRARY_PATH="${PREFIX}/lib"
	export LDLIBS="-ldl -lpthread"
	if [[ ${ARCH} == "aarch64" ]]; then
		export EGL=1
	fi
fi

make CC="${CC}" PREFIX="${PREFIX}" -j ${CPU_COUNT} install
