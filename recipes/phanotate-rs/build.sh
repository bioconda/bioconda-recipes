#!/usr/bin/env bash
set -euo pipefail

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

# Install binary to PREFIX/bin
cargo install --locked --root "$PREFIX" --path .
