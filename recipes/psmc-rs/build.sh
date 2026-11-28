#!/bin/bash
set -euxo pipefail

# conda-build does not pass HOME through; keep cargo's registry in the work directory.
export CARGO_HOME="$(pwd)/.cargo"

# The licenses of every Rust dependency, shipped with the package.
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

cargo install -v --locked --no-track --root "${PREFIX}" --path .
