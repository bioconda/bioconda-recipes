#!/bin/bash

set -euxo pipefail

# spoars-py is the pyo3/maturin package. It is a member of the spoars workspace
# and depends on the parent `spoars` crate by path, so build from within its
# subdirectory of the source tree.
cd spoars-py

# The extension is built abi3 (pyo3 abi3-py310). Allow building the abi3 wheel
# with a Python interpreter newer than the abi3 floor across the bioconda matrix.
export PYO3_USE_ABI3_FORWARD_COMPATIBILITY=1

# Build the cargo dependency graph from the committed (workspace) Cargo.lock
# (--locked) so the wheel pins the exact crate versions the project tests
# against. pip (PEP 517) forwards this to maturin via MATURIN_PEP517_ARGS.
export MATURIN_PEP517_ARGS="--locked"

${PYTHON} -m pip install . --no-deps --no-build-isolation -vv

# Capture the verbatim license text of every Cargo dependency into a bundle that
# ships with the package (see meta.yaml license_file). Run after the build so
# the crate sources are already fetched into CARGO_HOME.
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
