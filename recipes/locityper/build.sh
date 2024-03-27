#!/bin/bash -euo

if [ "$(uname)" == "Darwin" ]; then
    export HOME="/Users/distiller"
    export HOME=`pwd`
fi

export C_INCLUDE_PATH="$BUILD_PREFIX/include:$C_INCLUDE_PATH"
export LIBRARY_PATH="$BUILD_PREFIX/lib:$LIBRARY_PATH"

git clone https://github.com/smarco/WFA2-lib WFA2
cargo install --no-track --verbose --root "${PREFIX}" --path .

