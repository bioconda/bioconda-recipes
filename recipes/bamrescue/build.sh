#!/bin/bash
set -euo pipefail

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CARGO_TERM_COLOR=never
export RUSTFLAGS="-C target-cpu=generic"

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

RUST_BACKTRACE=1
cargo install --locked --no-track --path . --root "${PREFIX}"

"${STRIP}" "$PREFIX/bin/bamrescue"
