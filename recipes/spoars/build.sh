#!/bin/bash

set -euo pipefail

export RUST_BACKTRACE=1

# Capture the verbatim license text of every Cargo dependency into a bundle that
# ships with the package (see meta.yaml license_file).
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

# --locked builds from the committed Cargo.lock for a reproducible dependency
# graph; --no-track skips writing the install receipt into ${PREFIX}. The
# default `cli` feature is enabled, which pulls needletail's vendored C
# compression (zstd/lzma); it is compiled statically into the binary by ${CC},
# so no host libraries are required.
cargo install --no-track --locked --verbose --root "${PREFIX}" --path .
