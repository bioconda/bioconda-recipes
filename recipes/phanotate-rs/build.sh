#!/usr/bin/env bash
set -euo pipefail

# Install binary to PREFIX/bin
cargo install --locked --root "$PREFIX" --path .
