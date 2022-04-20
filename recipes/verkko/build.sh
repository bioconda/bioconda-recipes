#!/bin/bash
set -e

pushd src
pushd rukki
rm Cargo.lock
cargo fetch -vv --manifest-path rukki/Cargo.toml
cargo clean
cargo build --release
popd
make clean && make -j$CPU_COUNT
popd

mkdir -p "$PREFIX/bin"
cp -r bin/* $PREFIX/bin/
cp -r lib/* $PREFIX/lib/
