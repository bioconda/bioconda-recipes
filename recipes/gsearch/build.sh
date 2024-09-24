#!/bin/bash -euo

set -xe

# build statically linked binary with Rust
RUST_BACKTRACE=1 cargo install --features simdeez_f --verbose --path . --root $PREFIX
