#!/bin/bash
export CFLAGS="${CFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L{$PREFIX}/lib"
export C_INCLUDE_PATH=${PREFIX}/include

if [[ "$target_platform" == osx-64 ]]; then
    SDKROOT=$(xcrun --sdk macosx --show-sdk-path)
    echo "-isysroot is ${SDKROOT}"
    export CFLAGS="${CFLAGS} -isysroot ${SDKROOT}"
    export LDFLAGS="${LDFLAGS} -isysroot ${SDKROOT}"
fi

$PYTHON setup.py install --single-version-externally-managed --record=record.txt
