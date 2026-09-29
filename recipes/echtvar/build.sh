#!/bin/bash
set -eou pipefail

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3"

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

export RUSTC_BOOTSTRAP=1
export RUST_BACKTRACE=1
export RUSTFLAGS="${RUSTFLAGS:-}"
export RUSTFLAGS="${RUSTFLAGS//-C target-feature=+crt-static/}"
cargo install -v --no-track --locked --root "${PREFIX}" --path .
