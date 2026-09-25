#!/bin/bash
set -euo pipefail

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

RUST_BACKTRACE=1 cargo install --no-track --locked --verbose --root "${PREFIX}" --path crates/sracha
