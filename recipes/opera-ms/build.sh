#!/bin/bash
set -euxo pipefail

# cargo's home inside the build directory (conda-build doesn't pass HOME on),
# and git through the command line for crate downloads
export CARGO_HOME="$(pwd)/.cargo"
export CARGO_NET_GIT_FETCH_WITH_CLI=true

# licences of the Rust dependencies, shipped with the package
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

# the C++ (SIGMA, OPERA-LG) is compiled by crates/opera-ms-sys/build.rs with
# conda's compilers ($CC, $CXX)
cargo install --locked --no-track --verbose --root "${PREFIX}" --path crates/opera-ms