#!/bin/bash

# Explicitly tell Rust where to find macOS system libraries
if [[ "${target_platform}" == osx-* ]]; then
    export RUSTFLAGS="${RUSTFLAGS} -L ${CONDA_BUILD_SYSROOT}/usr/lib"
fi

# Bundle all dependency licenses
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

# Install the binary
cargo install --locked --root "$PREFIX" --path .
