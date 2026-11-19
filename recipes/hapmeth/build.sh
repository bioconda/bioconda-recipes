#!/bin/bash
set -euxo pipefail

# conda-build does not pass HOME through; keep cargo's cache in the work dir.
export CARGO_HOME="$(pwd)/.cargo"

# Third-party crate licences, shipped via about/license_file.
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

cargo install --no-track --locked --verbose --root "${PREFIX}" --path .
