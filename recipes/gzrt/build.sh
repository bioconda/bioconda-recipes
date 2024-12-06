#!/bin/bash

# Exit on error
set -xe

if [ -z "$PREFIX" ]; then
    echo "PREFIX environment variable not set"
    exit 1
fi

export CFLAGS="${CFLAGS:-} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS:-} -L${PREFIX}/lib"
export CPATH="${PREFIX}/include"

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

if ! make -j"${CPU_COUNT}"; then
    echo "Build failed"
    exit 1
fi

if [ ! -f gzrecover ]; then
    echo "Build did not produce gzrecover binary"
    exit 1
fi

chmod 755 gzrecover

if ! mkdir -p "$PREFIX/bin"; then
    echo "Failed to create bin directory"
    exit 1
fi

if ! cp gzrecover "$PREFIX/bin/"; then
    echo "Failed to install gzrecover"
    exit 1
fi
