#!/bin/bash
set -euxo pipefail

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
cargo install --locked --root "${PREFIX}" --path .