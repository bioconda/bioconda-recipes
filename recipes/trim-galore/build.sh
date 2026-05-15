#!/bin/bash
set -xeuo pipefail

# Native cargo build using the conda-forge Rust toolchain.
# --locked: refuse to update Cargo.lock; build exactly the resolution we ship.
cargo build --release --locked

mkdir -p "${PREFIX}/bin"
install -m 0755 target/release/trim_galore "${PREFIX}/bin/trim_galore"
