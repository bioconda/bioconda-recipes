#!/bin/bash
set -euo pipefail

# Build the rneat binary from the workspace and install it into $PREFIX/bin.
# --locked uses the committed Cargo.lock for a reproducible build.
cargo install --no-track --locked --bin rneat --root "${PREFIX}" --path rneat
