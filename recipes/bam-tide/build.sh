#!/usr/bin/env bash
set -euo pipefail

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3 -Wno-implicit-function-declaration"


export CARGO_NET_GIT_FETCH_WITH_CLI=true

# License bundle for Rust deps
if command -v cargo-bundle-licenses >/dev/null 2>&1; then
    cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
else
    echo "cargo-bundle-licenses not found, skipping license bundling"
    touch THIRDPARTY.yml
fi

# Install all binaries into $PREFIX/bin
export RUST_BACKTRACE=full

cargo install --verbose --no-track --root "$PREFIX" --path ./ --locked
