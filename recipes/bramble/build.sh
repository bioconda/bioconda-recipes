#!/bin/bash

set -xe

# Point bindgen to Conda's libclang location
if [ -d "${BUILD_PREFIX}/lib" ]; then
    export LIBCLANG_PATH="${BUILD_PREFIX}/lib"
else
    export LIBCLANG_PATH="${PREFIX}/lib"
fi

# Move into the bramble-cli crate directory where Cargo.toml lives
cd bramble-cli

# Bundle Rust dependencies licenses
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

# Copy THIRDPARTY.yml to the source root directory for conda license checking
cp THIRDPARTY.yml ..

# Build and install the Rust binary using cargo
cargo install --no-track --verbose --root "${PREFIX}" --path .

# Create a symbolic link so both `bramble` and `bramble-rs` work
ln -s "${PREFIX}/bin/bramble-rs" "${PREFIX}/bin/bramble"