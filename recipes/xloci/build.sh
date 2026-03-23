#!/bin/bash

# Add workaround for SSH-based Git connections from Rust/cargo.  See https://github.com/rust-lang/cargo/issues/2078 for details.
# We set CARGO_HOME because we don't pass on HOME to conda-build, thus rendering the default "${HOME}/.cargo" defunct.
export CARGO_NET_GIT_FETCH_WITH_CLI=true 
export CARGO_HOME="${BUILD_PREFIX}/.cargo"
export RUST_BACKTRACE=1

cd xloci
cargo-bundle-licenses --format yaml --output "${SRC_DIR}/THIRDPARTY.yml"

# build statically linked binary with Rust
cargo install --verbose --locked --path . --no-track --root "${PREFIX}"

