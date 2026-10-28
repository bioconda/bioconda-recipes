#!/bin/bash
set -euxo pipefail

cargo-bundle-licenses --format yaml --output "${SRC_DIR}/THIRDPARTY.yml"

cargo install --no-track --locked --verbose --root "${PREFIX}" --path .
