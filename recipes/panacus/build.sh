#!/bin/bash -euo

set -xe

mkdir -p $PREFIX/bin

RUST_BACKTRACE=1 CARGO_HOME="${BUILD_PREFIX}/.cargo" cargo install --no-track --locked --verbose --root \"${PREFIX}\" --path .

cp scripts/panacus-visualize.py $PREFIX/bin/panacus-visualize
