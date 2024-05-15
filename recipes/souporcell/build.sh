#!/usr/bin/env bash
export CFLAGS="${CFLAGS} -fcommon"
export CXXFLAGS="${CFLAGS} -fcommon"

# Add workaround for SSH-based Git connections from Rust/cargo.  See https://github.com/rust-lang/cargo/issues/2078 for details.
# We set CARGO_HOME because we don't pass on HOME to conda-build, thus rendering the default "${HOME}/.cargo" defunct.
export CARGO_NET_GIT_FETCH_WITH_CLI=true CARGO_HOME="$(pwd)/.cargo"

# Include scripts
cp stan_consensus.pickle $PREFIX/stan_consensus.pickle
cp *py $PREFIX
chmod +x $PREFIX/souporcell_pipeline.py

# Build statically linked binary with Rust
RUST_BACKTRACE=1 cargo install --locked --root "$PREFIX" --path troublet
RUST_BACKTRACE=1 cargo install --locked --root "$PREFIX" --path souporcell
