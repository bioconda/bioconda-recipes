#!/bin/bash -e

export C_INCLUDE_PATH="$PREFIX/include"
export LIBRARY_PATH="$PREFIX/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3 -Wno-implicit-function-declaration"

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

# build statically linked binary with Rust
RUST_BACKTRACE=1
cargo install --verbose --no-track --path . --root "${PREFIX}"
