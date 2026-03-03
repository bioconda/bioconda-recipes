#!/usr/bin/env bash
set -euo pipefail

export CARGO_NET_GIT_FETCH_WITH_CLI=true

# License bundle for Rust deps
if command -v cargo-bundle-licenses >/dev/null 2>&1; then
    cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
else
    echo "cargo-bundle-licenses not found, skipping license bundling"
    touch THIRDPARTY.yml
fi

# Install all binaries into $PREFIX/bin
cargo install -v --no-track --root "$PREFIX" --path ./bam_tide
