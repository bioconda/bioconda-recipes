#!/bin/bash

set -ex

export CXXFLAGS="${CXXFLAGS} -O2"
export CFLAGS="${CFLAGS} -O2"

if [[ "${target_platform}" == linux-aarch64 ]]; then
    export CXXFLAGS="${CXXFLAGS} -march=armv8-a+crc+crypto -mtune=generic"
    export CFLAGS="${CFLAGS} -march=armv8-a+crc+crypto -mtune=generic"
    
fi

${PYTHON} -m pip install . --no-deps -vv

