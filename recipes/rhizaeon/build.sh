#!/bin/bash
set -ex

# The Python package lives in the rhizaeon/ subdirectory of the HyphAeon
# monorepo; its maturin manifest-path resolves workspace members via the
# repo-root rust/Cargo.toml, which the tarball provides.
cd rhizaeon
${PYTHON} -m pip install . --no-build-isolation --no-deps --no-cache-dir -vvv
