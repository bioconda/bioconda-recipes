#!/bin/bash
set -euo pipefail

# Install Rust binary
cargo install --locked --path . --root "$PREFIX"
rm -rf "$PREFIX/.crates*"
