#!/usr/bin/env bash

set -euo pipefail

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

cargo install --verbose --locked --no-track --root "$PREFIX" --path .

"${STRIP}" "$PREFIX/bin/fast"
