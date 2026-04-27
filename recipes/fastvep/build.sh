#!/usr/bin/env bash
set -euo pipefail

# Keep cargo caches inside the build sandbox.
export CARGO_HOME="${SRC_DIR}/.cargo"

# Generate a bundled third-party license manifest (bioconda convention for Rust).
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

# Build and install both workspace binaries into $PREFIX/bin/.
cargo install --no-track --locked --verbose \
    --path crates/fastvep-cli \
    --root "${PREFIX}"

cargo install --no-track --locked --verbose \
    --path crates/fastvep-web \
    --root "${PREFIX}"
