#!/bin/bash -euo

if [ "$(uname)" == "Darwin" ]; then
    export HOME="/Users/distiller"
    export HOME=`pwd`
fi

export C_INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"

if [[ `uname` == 'Darwin' ]]; then
    export MACOSX_DEPLOYMENT_TARGET=10.11
fi

git clone https://github.com/smarco/WFA2-lib WFA2

# build statically linked binary with Rust
RUST_BACKTRACE=1
cargo install --no-track --verbose --root "${PREFIX}" --path .
