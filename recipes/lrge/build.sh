#!/usr/bin/env bash

set -eo pipefail

export INCLUDE_PATH="${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3 -fcommon"
export CXXFLAGS="${CXXFLAGS} -O3 -fcommon -I${PREFIX}/include"

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

RUST_BACKTRACE=full cargo install -v --locked --no-track --root "$PREFIX" --path lrge
