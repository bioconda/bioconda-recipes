#!/usr/bin/env bash

set -xe

cd rust
cp gemBS/Cargo.toml.in gemBS/Cargo.toml
cargo build --release

mkdir -p $PREFIX/bin
cp -r target/release/gem_bs $PREFIX/bin/
echo addi1
ls -ahl
echo addi2
ls -ahl target
echo addi3
ls -ahl target/release
echo addi4
ls -ahl target/release/build
echo "List bin prefix contenets recursively"
ls -ahlR $PREFIX/bin/
chmod +x $PREFIX/bin/gemBS
