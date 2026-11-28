#!/bin/bash
set -euxo pipefail

# Licenses of all Rust dependencies, required by conda-forge/bioconda.
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

RUST_BACKTRACE=1 cargo install --locked --no-track --verbose --root "${PREFIX}" --path crates/ripscape-cli
