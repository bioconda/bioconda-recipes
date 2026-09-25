#!/bin/bash
set -ex

# Export maturin build arguments for PyO3 extension module
export MATURIN_PEP517_ARGS="--features=pyo3/extension-module"

# Build the Python wheel using maturin
maturin build --release --features=pyo3/extension-module --out dist

# Install the wheel
${PYTHON} -m pip install dist/iscc_sum-*.whl --no-deps -vv
