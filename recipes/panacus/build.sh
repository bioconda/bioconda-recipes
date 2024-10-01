#!/bin/bash -euo

RUST_BACKTRACE=1 CARGO_HOME="${BUILD_PREFIX}/.cargo" cargo install --no-track --verbose --root "${PREFIX}" --path .

mkdir -p $PREFIX/bin
cp $BUILD_PREFIX/.cargo/bin/panacus $PREFIX/bin 
cp scripts/panacus-visualize.py $PREFIX/bin/panacus-visualize
