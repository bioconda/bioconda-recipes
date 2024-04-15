#!/bin/bash
set -ex

# Add workaround for SSH-based Git connections from Rust/cargo.  See https://github.com/rust-lang/cargo/issues/2078 for details.
# We set CARGO_HOME because we don't pass on HOME to conda-build, thus rendering the default "${HOME}/.cargo" defunct.
export CARGO_NET_GIT_FETCH_WITH_CLI=true CARGO_HOME="${BUILD_PREFIX}/.cargo"
export RUST_BACKTRACE=full

cargo install --verbose --path . --root $PREFIX --locked