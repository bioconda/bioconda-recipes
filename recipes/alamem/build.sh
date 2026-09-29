#!/bin/bash
set -xeuo pipefail

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
RUST_BACKTRACE=1 cargo install --verbose --no-track --locked --root "$PREFIX" --path .
