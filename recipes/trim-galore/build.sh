#!/bin/bash
set -xeuo pipefail

# Native cargo build using the conda-forge Rust toolchain.
# `cargo install` is target-triple-aware: bioconda's `{{ compiler('rust') }}`
# activation sets CARGO_BUILD_TARGET to e.g. x86_64-conda-linux-gnu, so the
# build output lives at target/<triple>/release/, not target/release/.
# `cargo install --root "${PREFIX}"` handles the path resolution for us and
# installs straight to $PREFIX/bin/.
#
# `--locked`: refuse to update Cargo.lock; build exactly the resolution we ship.
# `--no-track`: don't write .crates.toml tracking into $PREFIX.
# Rust recipes bundle their third-party licences; `license_file` lists the output.
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

cargo install -v --locked --no-track --root "${PREFIX}" --path .
