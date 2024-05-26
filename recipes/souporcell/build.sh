#!/usr/bin/env bash
export CFLAGS="${CFLAGS} -fcommon"
export CXXFLAGS="${CFLAGS} -fcommon"
INSTALL_PREFIX="${PREFIX}" make -j${CPU_COUNT}

# Add workaround for SSH-based Git connections from Rust/cargo.  See https://github.com/rust-lang/cargo/issues/2078 for details.
# We set CARGO_HOME because we don't pass on HOME to conda-build, thus rendering the default "${HOME}/.cargo" defunct.
export CARGO_NET_GIT_FETCH_WITH_CLI=true CARGO_HOME="$(pwd)/.cargo"

# Include scripts
cp stan_consensus.pickle $PREFIX/bin/stan_consensus.pickle
cp *py $PREFIX/bin
chmod +x $PREFIX/bin/souporcell_pipeline.py
# Scripts expect the binary located in the following folder
mkdir -p $PREFIX/bin/souporcell/target/release
mkdir -p $PREFIX/bin/troublet/target/release
# Build statically linked binary with Rust
RUST_BACKTRACE=1 cargo install --locked --root "$PREFIX/bin/souporcell/target/release" --path troublet
RUST_BACKTRACE=1 cargo install --locked --root "$PREFIX/bin/troublet/target/release/" --path souporcell
