#!/bin/bash

# -e = exit on first error
# -x = print every executed command
set -ex

export RUST_BACKTRACE=1

# Build the package using maturin - should produce *.whl files.
maturin build --interpreter "${PYTHON}" -b pyo3 --release --strip --manylinux off

# Install *.whl files using pip
${PYTHON} -m pip install target/wheels/*.whl --no-deps --no-build-isolation --no-cache-dir -vv
