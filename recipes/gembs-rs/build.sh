#!/usr/bin/env bash

set -xe

cd rust
cp gemBS/Cargo.toml.in gemBS/Cargo.toml
cargo build --release --package gem_bs

mkdir -p $PREFIX/bin

if [ "$(uname)" = "Darwin" ]; then
    cp target/$(uname -m)-apple-darwin/release/gem_bs $PREFIX/bin/gemBS
else
    cp target/$(uname -m)-unknown-linux-gnu/release/gem_bs $PREFIX/bin/gemBS
fi
chmod +x $PREFIX/bin/gemBS
