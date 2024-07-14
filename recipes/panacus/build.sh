#!/bin/bash -euo

RUST_BACKTRACE=1 CARGO_HOME="${BUILD_PREFIX}/.cargo" cargo build --release

mkdir -p $PREFIX/bin
cp target/release/panacus $PREFIX/bin 
cp scripts/panacus-visualize.py $PREFIX/bin/panacus-visualize
