#!/bin/bash

# -e = exit on first error
# -x = print every executed command
set -ex

# build statically linked binary with Rust
RUST_BACKTRACE=1
# Build the package using maturin - should produce *.whl files.
maturin build --interpreter "${PYTHON}" -b pyo3 --release --strip --compatibility "manylinux2014"

# Install *.whl files using pip
$PYTHON -m pip install target/wheels/*.whl --no-deps --no-build-isolation --no-cache-dir -vvv
