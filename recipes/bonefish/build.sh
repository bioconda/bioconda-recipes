#!/bin/bash
set -xeuo pipefail

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
RUST_BACKTRACE=1 cargo install --no-track --locked --verbose --root "${PREFIX}" --path bonefish --features jemalloc
