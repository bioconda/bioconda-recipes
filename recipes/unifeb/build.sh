#!/bin/bash

set -xeuo

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
# build statically linked binary with Rust
RUST_BACKTRACE=1 cargo install --verbose --path . --root $PREFIX --no-track
