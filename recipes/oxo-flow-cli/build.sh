#!/bin/bash -e

set -x

# HOME is not passed to conda-build, so cargo's default "${HOME}/.cargo"
# resolves to a non-absolute "UNKNOWN" path and cargo-bundle-licenses panics
# on macOS. Point CARGO_HOME at an absolute path instead.
export CARGO_HOME="${BUILD_PREFIX}/.cargo"

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

cargo install --no-track --locked --verbose --root "${PREFIX}" --path crates/oxo-flow-cli

set +x
