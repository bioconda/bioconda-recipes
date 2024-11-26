#!/usr/bin/env bash

set -euo pipefail

export CFLAGS="${CFLAGS} -fcommon"
export CXXFLAGS="${CFLAGS} -fcommon"

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

RUST_BACKTRACE=full cargo install -v --locked --no-track --root "$PREFIX" --path lrge