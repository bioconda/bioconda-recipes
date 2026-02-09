#!/bin/bash

# -e = exit on first error
# -x = print every executed command
set -ex

curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain nightly --profile=minimal -y

export PATH="$HOME/.cargo/bin:$PATH"

if [[ "${target_platform}" == osx-* ]]; then
    # Ensure maturin produces wheels tagged for the conda macOS deployment target.
    # Without this, wheels can be tagged as macosx_26_0_* and pip rejects them.
    export MACOSX_DEPLOYMENT_TARGET=11.3
    export MACOS_DEPLOYMENT_TARGET=11.3
    export SYSTEM_VERSION_COMPAT=0
fi

cd py_cli

maturin build --interpreter "${PYTHON}" --release --strip -b bin --out dist

$PYTHON -m pip install dist/*.whl --no-deps --no-build-isolation --no-cache-dir -vvv
