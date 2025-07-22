#!/bin/bash -e

# Add workaround for SSH-based Git connections from Rust/cargo.  See https://github.com/rust-lang/cargo/issues/2078 for details.
# We set CARGO_HOME because we don't pass on HOME to conda-build, thus rendering the default "${HOME}/.cargo" defunct.
export CARGO_NET_GIT_FETCH_WITH_CLI=true CARGO_HOME="$(pwd)/.cargo"

# build statically linked binary with Rust
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
RUST_BACKTRACE=1 C_INCLUDE_PATH=$PREFIX/include LIBRARY_PATH=$PREFIX/lib cargo install -v --locked --no-track --root $PREFIX --path .
