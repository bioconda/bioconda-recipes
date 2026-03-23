#!/bin/bash -e

# Vendor hgvs-rs with NR_ transcript fix (patched in Cargo.toml via [patch.crates-io]).
# Remove once https://github.com/varfish-org/hgvs-rs/pull/256 is merged and released.
git clone https://github.com/nh13/hgvs-rs.git vendor/hgvs-rs
cd vendor/hgvs-rs && git checkout cf0e5a8d1b9a2ae3e883a58826f397aa6cb52e23 && cd ../..

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

CARGO_PROFILE_RELEASE_LTO=thin \
cargo install --no-track --locked --verbose --root "${PREFIX}" --path . --features benchmark,hgvs-rs
