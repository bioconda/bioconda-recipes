#!/usr/bin/env bash
set -euo pipefail

# Bundle licenses of all vendored Rust dependencies for the MIT-compliant package.
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

# rammap is a Cargo workspace; the binary lives in the `rammap` member crate.
cargo install --no-track --locked --root "$PREFIX" --path rammap
