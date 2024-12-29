#!/bin/bash -eu

set -xe

OS=$(uname)
if [[ ${OS} == "Linux" ]]; then
	export C_INCLUDE_PATH="${PREFIX}/include"
	export LIBRARY_PATH="${PREFIX}/lib"
	export LDLIBS="-ldl -lpthread"
fi

make CC="${CC}" PREFIX="${PREFIX}" -j ${CPU_COUNT} install
