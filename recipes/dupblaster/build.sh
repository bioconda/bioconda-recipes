#!/bin/bash
set -euo pipefail

export RUST_BACKTRACE=1

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

cargo install --no-track --locked --verbose --root "${PREFIX}" --path .
