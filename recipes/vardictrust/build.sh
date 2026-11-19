#!/usr/bin/env bash
set -euo pipefail

# Conda-build sandboxing:
# Conda-build strips or randomizes HOME, which breaks default Cargo paths (~/.cargo).
# Explicitly anchor CARGO_HOME to the source build directory.
export CARGO_HOME="${SRC_DIR:-$(pwd)}/.cargo"
export CARGO_NET_GIT_FETCH_WITH_CLI=true
export RUST_BACKTRACE=1

# Ensure sandboxed cache cleanup on exit or failure
trap 'rm -rf "$CARGO_HOME"' EXIT

# Bundle third-party licenses required by Bioconda and Conda-Forge policies
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

# Install the binary into conda prefix bin
cargo install --no-track --locked --verbose --root "${PREFIX}" --path crates/vardictrust

# Clean up temporary cargo cache and install records to prevent bloat
rm -rf "$CARGO_HOME"
rm -f "${PREFIX}/.crates.toml" "${PREFIX}/.crates2.json"
