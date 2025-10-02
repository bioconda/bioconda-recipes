#!/bin/bash 

set -xeuo

pushd covar

cargo-bundle-licenses --format yaml --output ../THIRDPARTY.yml

popd

# build statically linked binary with Rust:
RUST_BACKTRACE=1 
cargo install --no-track --verbose --root "${PREFIX}" --path ./covar --all-features

