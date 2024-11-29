#!/bin/bash -eu

set -xe

export C_INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDLIBS="-ldl -lpthread"

make CC="${CC}" PREFIX="${PREFIX}" -j ${CPU_COUNT} install
