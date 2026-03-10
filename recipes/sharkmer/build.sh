#!/bin/bash
set -euo pipefail

# $SRC_DIR is the tarball root (sharkmer-1.0.x/)
# The Rust crate is one level deeper
cd "${SRC_DIR}/sharkmer"

cargo install --locked --no-track --root "${PREFIX}" --path .
