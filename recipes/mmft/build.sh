#!/bin/bash
set -ex

RUST_BACKTRACE=full

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

cargo install -v --locked --root "$PREFIX" --path . --no-track
