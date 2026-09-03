#!/bin/bash
set -euo pipefail

cd pathotypr-core
cargo install --no-track --locked --root "${PREFIX}" --path .

cargo-bundle-licenses \
  --format yaml \
  --output "${SRC_DIR}/THIRDPARTY.yml"
