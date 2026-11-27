#!/bin/bash
set -euo pipefail

# Keep cargo's registry inside the build tree (conda-build cleans it up).
export CARGO_HOME="${SRC_DIR}/.cargo-home"

# 1. Licences of every dependency, for the package's licence files (the wheel bundles their code).
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

# 2. The extension module and the Python package.
"${PYTHON}" -m pip install . -vv --no-deps --no-build-isolation
