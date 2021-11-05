#!/bin/bash -e

export RUSTFLAGS="-C target-cpu=native"
cargo build --release
cargo install --path . --root $PREFIX

