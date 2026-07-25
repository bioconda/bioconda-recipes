#!/bin/bash

set -xe

# Ensure C compiler / libclang environment variables are active for bindgen
export LIBCLANG_PATH="${PREFIX}/lib"

# Move into the bramble-cli crate directory where Cargo.toml lives
cd bramble-cli

# Bundle Rust dependencies licenses (Bioconda compliance check)
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

# Build and install the Rust binary using cargo
cargo install --no-track --verbose --root "${PREFIX}" --path bramble-cli

# Create a symbolic link so both `bramble` and `bramble-rs` work
ln -s "${PREFIX}/bin/bramble-rs" "${PREFIX}/bin/bramble"