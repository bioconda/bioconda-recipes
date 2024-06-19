#!/usr/bin/env bash

set -xe

cd rust
cp gemBS/Cargo.toml.in gemBS/Cargo.toml
cargo build --release --package gem_bs

mkdir -p $PREFIX/bin

find ../ -name "*gem_bs*"

ls -ahl target/release
echo addi4
cp target/release/gem_bs $PREFIX/bin/gemBS

echo "List bin prefix contenets recursively"
ls -ahlR $PREFIX/bin/
chmod +x $PREFIX/bin/gemBS
