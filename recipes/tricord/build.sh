#!/bin/bash
set -euo pipefail

export RUST_BACKTRACE=1

export BINDGEN_EXTRA_CLANG_ARGS="${CFLAGS} ${CPPFLAGS}"

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

cargo install --no-track --locked --verbose --root "${PREFIX}" --path .
