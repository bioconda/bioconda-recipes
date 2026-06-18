#!/bin/bash
set -euo pipefail

# Bundle the licenses of all (Rust) dependencies into THIRDPARTY.yml so they
# ship with the package, per conda-forge/Bioconda policy. Run from the workspace
# root so every transitive crate in Cargo.lock is captured. Referenced by
# about.license_file in meta.yaml.
#
# --previous reuses the committed THIRDPARTY.yml, which carries hand-filled
# license texts for crates that publish no LICENSE file (e.g. the noodles
# family, r-efi, vectorize, wasip2). --check-previous fails the build if a
# dependency changes such that the bundle would no longer be a subset of the
# committed file — i.e. a new/updated crate whose license isn't yet recorded.
# Regenerate and re-commit THIRDPARTY.yml when that happens.
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml \
    --previous THIRDPARTY.yml --check-previous

# Build the rneat binary from the workspace and install it into $PREFIX/bin.
# --locked uses the committed Cargo.lock for a reproducible build.
cargo install --no-track --locked --bin rneat --root "${PREFIX}" --path rneat