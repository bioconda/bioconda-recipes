#!/bin/bash -euo

# Use the portable per-target cargo config (x86-64-v3 / Neoverse-N1 /
# Apple-A14 baselines) for the conda build, mirroring piscem: explicit even
# though the tracked config.toml carries the same content, and a guard in
# case the two ever diverge.
mv .cargo/config-portable.toml .cargo/config.toml

# Build and install the cuttlefish binary from the Rust workspace. The CLI
# crate carries the `cuttlefish` binary; --locked holds the checked-in
# Cargo.lock, and --no-track skips cargo's install metadata, which does not
# belong in a conda package.
cargo install --locked --no-track --root "${PREFIX}" --path crates/cuttlefish-rs-cli
