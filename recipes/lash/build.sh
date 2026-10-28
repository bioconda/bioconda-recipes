#!/bin/bash

set -xeuo pipefail

# cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

export PATH=$PREFIX/bin:$PATH

export RUSTC_BOOTSTRAP=1

RUST_BACKTRACE=1 cargo install --verbose --locked --path . --root $PREFIX --no-track
