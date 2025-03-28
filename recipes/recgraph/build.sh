#!/bin/bash -euo

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

RUST_BACKTRACE=1
cargo install --no-track --verbose --root "${PREFIX}" --path .
