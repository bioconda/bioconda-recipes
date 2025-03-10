#!/bin/bash

# -e = exit on first error
# -x = print every executed command
set -ex

curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain nightly --profile=minimal -y

export PATH="$HOME/.cargo/bin:$PATH"

cd py_cli

maturin build --interpreter "${PYTHON}" --release --strip -b bin --out dist

$PYTHON -m pip install dist/*.whl --no-deps --no-build-isolation --no-cache-dir -vvv
