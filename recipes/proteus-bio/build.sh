#!/bin/bash
set -euxo pipefail

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
RUST_BACKTRACE=1 cargo install --locked --no-track --verbose --root "${PREFIX}" --path crates/proteus-cli
