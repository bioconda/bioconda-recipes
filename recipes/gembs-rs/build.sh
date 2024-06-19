#!/usr/bin/env bash

set -xe

cd rust
cp gemBS/Cargo.toml.in gemBS/Cargo.toml
cargo build --release --package gem_bs

mkdir -p $PREFIX/bin
ls -ahl target/release
echo addi4
cp ../target/release/gem_bs $PREFIX/bin/gemBS
echo addi1
ls -ahl
echo addi2
ls -ahl target
echo addi3
ls -ahl target/release/build
echo "List bin prefix contenets recursively"
ls -ahlR $PREFIX/bin/
chmod +x $PREFIX/bin/gemBS
