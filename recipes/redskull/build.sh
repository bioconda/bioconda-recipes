#!/bin/bash
set -euo pipefail

export RUST_BACKTRACE=1

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3"
export LD_LIBRARY_PATH="${PREFIX}/lib${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
export DYLD_FALLBACK_LIBRARY_PATH="${PREFIX}/lib${DYLD_FALLBACK_LIBRARY_PATH:+:${DYLD_FALLBACK_LIBRARY_PATH}}"

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

cargo install --no-track --locked --verbose --root "${PREFIX}" --path .
