#!/usr/bin/env bash

set -euo pipefail

export INCLUDE_PATH="${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3 -fcommon"
export CXXFLAGS="${CFLAGS} -O3 -fcommon -I${PREFIX}/include"

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

RUST_BACKTRACE=full RUSTFLAGS="-C linker=$CC" cargo install -v --locked --no-track --root "$PREFIX" --path lrge