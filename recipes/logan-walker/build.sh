#!/bin/bash
set -euo pipefail

cd walker
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
cargo install --no-track --locked --verbose --root "${PREFIX}" --path .
