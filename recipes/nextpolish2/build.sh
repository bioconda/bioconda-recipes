#!/usr/bin/env bash
set -euo pipefail
set -x

export INCLUDE_PATH="${PREFIX}/include"
export CPPFLAGS="${CPPFLAGS:-} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS:-} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS:-} -O3 -Wno-implicit-function-declaration"
export CXXFLAGS="${CXXFLAGS:-} -O3"

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

export RUST_BACKTRACE=1

cargo install --verbose --no-track --path . --root "${PREFIX}"

