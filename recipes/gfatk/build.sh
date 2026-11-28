#!/bin/bash
set -euo pipefail

# Rust release builds strip debuginfo by default. On osx-64, conda-build's
# Mach-O post-processing then aborted with `llvm-otool -l ... died with
# SIGABRT` on the gfatk binary (bioconda/bioconda-recipes#70325). Hand
# conda-build an unstripped binary; it strips the result itself during
# packaging, so the shipped package is unaffected.
export CARGO_PROFILE_RELEASE_STRIP=none

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
cargo install --no-track --locked --verbose --root "${PREFIX}" --path .
