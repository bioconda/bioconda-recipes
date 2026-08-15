#!/bin/bash -euo

# Build and install the cuttlefish binary from the Rust workspace. The CLI
# crate carries the `cuttlefish` binary; --locked holds the checked-in
# Cargo.lock, and --no-track skips cargo's install metadata, which does not
# belong in a conda package.
cargo install --locked --no-track --root "${PREFIX}" --path crates/cuttlefish-rs-cli
