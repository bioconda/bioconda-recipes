#!/bin/bash -euo

# Add workaround for SSH-based Git connections from Rust/cargo.  See https://github.com/rust-lang/cargo/issues/2078 for details.
# We set CARGO_HOME because we don't pass on HOME to conda-build, thus rendering the default "${HOME}/.cargo" defunct.
export CARGO_NET_GIT_FETCH_WITH_CLI=true CARGO_HOME="$(pwd)/.cargo"

# Set C++ linking flags for macOS to ensure proper C++ standard library linking
if [[ "$OSTYPE" == "darwin"* ]]; then
    export RUSTFLAGS="-C link-arg=-L${PREFIX}/lib"
fi

# build statically linked binary with Rust
RUST_BACKTRACE=1 cargo install --features foldcomp --verbose --path . --root $PREFIX
