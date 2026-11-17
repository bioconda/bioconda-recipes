#!/bin/bash
set -euo pipefail
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
cargo install --no-track --locked --verbose --root "${PREFIX}" --path crates/amfsplit
# the culture reference, frozen files, V18 tree/model/metadata and the primer panel, where the binary looks
mkdir -p "${PREFIX}/share/amfsplit/naming"
cp -r parity/naming/inputs parity/naming/frozen_sources parity/naming/placement parity/naming/v18 "${PREFIX}/share/amfsplit/naming/"
cp -r panels "${PREFIX}/share/amfsplit/panels"
