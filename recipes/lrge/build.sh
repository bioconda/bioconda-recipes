#!/usr/bin/env bash

set -euo pipefail

# Make sure bindgen passes on our compiler flags.
export BINDGEN_EXTRA_CLANG_ARGS="${CPPFLAGS} ${CFLAGS} ${LDFLAGS}"

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

RUST_BACKTRACE=full cargo install -v --locked --no-track --root "$PREFIX" --path lrge