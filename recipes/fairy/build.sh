#!/bin/bash 

set -xeuo

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -Wno-implicit-function-declaration"

cargo-bundle-licenses --format yaml --output THIRD

# build statically linked binary with Rust
RUST_BACKTRACE=1
cargo install --verbose --path . --no-track --root "${PREFIX}"
