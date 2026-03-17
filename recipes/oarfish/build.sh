#!/bin/bash -euo

set -xe

curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain stable --profile=minimal -y
export PATH="$HOME/.cargo/bin:$PATH"


# build statically linked binary with Rust
RUST_BACKTRACE=1 RUSTFLAGS="-C linker=$CC" cargo install --verbose --root $PREFIX --path .
