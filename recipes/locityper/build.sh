#!/bin/bash -euo

if [ "$(uname)" == "Darwin" ]; then
    export HOME="/Users/distiller"
    export HOME=`pwd`
fi

export C_INCLUDE_PATH="$BUILD_PREFIX/include"
export LIBRARY_PATH="$BUILD_PREFIX/lib"
# export CFLAGS="-L$BUILD_PREFIX/lib"
# export RUSTFLAGS="-L$BUILD_PREFIX/lib -lz"

git clone https://github.com/smarco/WFA2-lib WFA2
cargo install --no-track --verbose --root "${PREFIX}" --path .

