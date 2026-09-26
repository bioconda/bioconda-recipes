#!/bin/bash
set -euxo pipefail

cd ConSTRain

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
cargo install \
  --no-track \
  --path . \
  --root "${PREFIX}" \
  --bin ConSTRain

"${STRIP}" "${PREFIX}/bin/ConSTRain"