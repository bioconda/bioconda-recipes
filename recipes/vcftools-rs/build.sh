#!/bin/bash
set -euxo pipefail

# The crate lives in vcftools-rs/; cargo-bundle-licenses has no
# --manifest-path option, so run it from there.
pushd vcftools-rs
# Third-party license notices for the bundled Rust crates.
cargo-bundle-licenses --format yaml --output ../THIRDPARTY.yml
popd

cargo install --no-track --locked --verbose --root "${PREFIX}" --path vcftools-rs
