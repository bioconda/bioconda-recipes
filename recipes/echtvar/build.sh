#!/bin/bash
set -o xtrace -o nounset -o pipefail -o errexit

export RUSTC_BOOTSTRAP=1
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3"

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

# build statically linked binary with Rust
cargo install --no-track --locked --root "${PREFIX}" --path .
