#!/bin/bash -e

# build statically linked binary with Rust
cargo install --path . --root $PREFIX
