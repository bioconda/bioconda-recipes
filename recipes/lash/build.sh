#!/bin/bash

set -xeuo

# cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

export PATH=$PREFIX/bin:$PATH

export RUSTUP_TOOLCHAIN=nightly

RUST_BACKTRACE=1 cargo install --verbose --path . --root $PREFIX --no-track
