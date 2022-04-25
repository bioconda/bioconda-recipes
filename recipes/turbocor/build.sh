#!/bin/bash -e

export CARGO_HOME="${BUILD_PREFIX}/.cargo"
export RUSTFLAGS="-C target-cpu=native"
export HDF5_DIR=$PREFIX
RUST_BACKTRACE=1 cargo build --release
cargo install --no-track --verbose --path . --root $PREFIX

