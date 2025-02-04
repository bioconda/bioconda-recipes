#!/bin/bash -euo

mkdir -p $PREFIX/bin

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
RUST_BACKTRACE=1 cargo install --no-track --verbose --root "${PREFIX}" --path .

cp scripts/panacus-visualize.py $PREFIX/bin/panacus-visualize
