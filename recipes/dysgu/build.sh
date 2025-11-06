#!/bin/bash

export CFLAGS="${CFLAGS} -O3 -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L{$PREFIX}/lib"
export C_INCLUDE_PATH="${PREFIX}/include"

if [[ "$target_platform" == "osx-64" || "$target_platform" == "osx-arm64" ]]; then
    SDKROOT=$(xcrun --sdk macosx --show-sdk-path)
    echo "-isysroot is ${SDKROOT}"
    export CFLAGS="${CFLAGS} -isysroot ${SDKROOT}"
    export LDFLAGS="${LDFLAGS} -isysroot ${SDKROOT}"
fi

${PYTHON} -m pip install . -vvv --no-deps --no-build-isolation --no-cache-dir
