#!/bin/bash -euo
set -xe

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -std=c11 -O3 -Wno-int-conversion -Wno-implicit-function-declaration"

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

cargo generate-lockfile
cargo update --package console --precise "0.15.11"
cargo update --package rust-htslib --precise "0.47"

# build statically linked binary with Rust
export RUST_BACKTRACE=1
cargo install --root "${PREFIX}" --no-track --locked --verbose --path .
