#!/bin/bash

# Exit on error
set -xe

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export CFLAGS="${CFLAGS:-} -O3 -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS:-} -L${PREFIX}/lib"
export CPATH="${PREFIX}/include"

mkdir -p "${PREFIX}/bin"

if [ -z "$PREFIX" ]; then
    echo "PREFIX environment variable not set"
    exit 1
fi

# If-body reserved to docker build
if [ ! -f "$(command -v cc)" ]; then
    # Ensure that the CC environment variable is set (for compiler)
    if [ -z "$CC" ]; then
        echo "CC environment variable not set, but it is required."
        exit 1
    fi

    # Create a temporary directory
    mkdir -p "$SRC_DIR/bin"

    # Create a symlink named cc that points to $CC
    CC_PATH="$(which "${CC}")"  
    if [ ! -x "${CC_PATH}" ]; then  
        echo "Could not find compiler at: ${CC_PATH}"  
        exit 1  
    fi  
    ln -sf "${CC_PATH}" "${SRC_DIR}/bin/cc"

    # Prepend the temporary directory to the PATH
    export PATH="${SRC_DIR}/bin:${PATH}"
fi

make CC="${CC}" -j"${CPU_COUNT}"
install -v -m 0755 gzrecover "${PREFIX}/bin"
