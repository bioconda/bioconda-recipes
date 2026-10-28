#!/bin/bash
set -euo pipefail
export MATURIN_PEP517_ARGS="--locked"
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
$PYTHON -m pip install . -vv --no-deps --no-build-isolation