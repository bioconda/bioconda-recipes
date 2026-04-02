#!/bin/bash
set -xeuo pipefail

export CARGO_HOME="${BUILD_PREFIX}/.cargo"
export RUST_BACKTRACE=1

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export BINDGEN_EXTRA_CLANG_ARGS="${CFLAGS} ${CPPFLAGS} ${LDFLAGS}"

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
cargo install --no-track --locked --verbose --root "${PREFIX}" --path .
