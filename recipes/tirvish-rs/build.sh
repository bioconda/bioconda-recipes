#!/bin/bash
set -euo pipefail

# Build + install only the tirvish binary (the crate also carries dev-only
# validator bins) into the conda prefix.
cargo install --no-track --locked --root "$PREFIX" --path . --bin tirvish

# Package is tirvish-rs; expose the crate name as an alias for discoverability.
ln -sf tirvish "$PREFIX/bin/tirvish_rs"
