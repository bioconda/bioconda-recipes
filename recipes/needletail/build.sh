#!/bin/bash

set -ex

# Build wheel and write to `dist`
maturin build --interpreter "${PYTHON}" --features python --release --strip --out dist

# Install Python library
${PYTHON} -m pip install dist/*.whl --no-deps --no-build-isolation --no-cache-dir -vvv
