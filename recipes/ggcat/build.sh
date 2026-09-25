#!/bin/bash -ex

export INCLUDE_PATH="${PREFIX}/include"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3 -Wno-implicit-function-declaration"

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

# Build statically linked binary with Rust
RUST_BACKTRACE=1
cargo install --no-track --verbose --root "${PREFIX}" --path crates/cmdline/ --locked
