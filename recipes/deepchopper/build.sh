#!/bin/bash
set -ex

# Build the package using Maturin
maturin build --release --strip --interpreter $PYTHON

# Install the wheel
$PYTHON -m pip install $WHEEL_PATH --no-deps -vv
