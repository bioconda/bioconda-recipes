#!/bin/bash
set -xeuo

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3 -Wno-implicit-function-declaration"

cargo-bundle-licenses --format yaml --output ../THIRDPARTY.yml

# build statically linked binary with Rust:
RUST_BACKTRACE=1
cargo install --no-track -v --root "${PREFIX}" --path . --all-features

"${STRIP}" "$PREFIX/bin/covar"
