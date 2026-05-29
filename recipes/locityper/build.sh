#!/bin/bash

set -xeuo pipefail

if [ "$(uname)" == "Darwin" ]; then
    export HOME="/Users/distiller"
    export HOME=`pwd`
    export MACOSX_DEPLOYMENT_TARGET=10.11
fi

export C_INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LIBCLANG_PATH="${PREFIX}/lib"

# htslib vendored build flags
export HTS_SYS_CONFIGURE_ARGS="--disable-plugins --disable-s3"
export CFLAGS="${CFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

git clone https://github.com/smarco/WFA2-lib WFA2

# build statically linked binary with Rust
RUST_BACKTRACE=1
cargo install --no-track --verbose --root "${PREFIX}" --path .
