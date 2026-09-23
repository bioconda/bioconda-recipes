#!/bin/bash
set -euxo pipefail

# Third-party license notices for the bundled Rust crates.
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml --manifest-path vcftools-rs/Cargo.toml

cargo install --no-track --locked --verbose --root "${PREFIX}" --path vcftools-rs
