#!/bin/bash
set -euo pipefail

# Build + install the release binary (named grf_rs) into the conda prefix.
cargo install --no-track --locked --root "$PREFIX" --path .

# The package is named grfmite-rs; also expose that as a command for discoverability.
# (TIR-Learner's grf_new.py looks for `grf_rs` on PATH by default.)
ln -sf grf_rs "$PREFIX/bin/grfmite-rs"
