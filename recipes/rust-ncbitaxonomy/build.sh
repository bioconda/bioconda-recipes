#!/bin/bash 

set -xeuo

if [ "$(uname)" == "Darwin" ]; then
    # Apparently the Home variable isn't set correctly
    export HOME="/Users/distiller"
    export HOME=`pwd`
fi


# build statically linked binary with Rust
RUST_BACKTRACE=1 C_INCLUDE_PATH="${PREFIX}/include" LD_LIBRARY_PATH="${PREFIX}/lib" \
    cargo install --no-track --verbose --root "${PREFIX}" --path .
