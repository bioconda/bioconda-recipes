#!/usr/bin/env bash

set -euxo pipefail

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

cargo install --locked --no-track --verbose --root "${PREFIX}" --path .

"${STRIP}" "${PREFIX}/bin/tdkc"
