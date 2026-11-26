#!/bin/bash
set -euxo pipefail

# conda-build does not pass HOME, so keep cargo's files in the build directory.
export CARGO_HOME="$(pwd)/.cargo"

# Licences of the Rust dependencies compiled into the binary.
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

cargo install --no-track --locked --verbose --root "${PREFIX}" --path .
