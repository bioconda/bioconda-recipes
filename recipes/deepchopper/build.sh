#!/bin/bash

# -e = exit on first error
# -x = print every executed command
set -ex

if [ `uname` == Darwin ]; then
  export HOME=`mktemp -d`
fi

curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain nightly --profile=minimal -y

export PATH="$HOME/.cargo/bin:$PATH"
export CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_LINKER="$CC"
export CARGO_TARGET_AARCH64_UNKNOWN_LINUX_GNU_LINKER="$CC"


# Build the package using maturin - should produce *.whl files.
maturin build --interpreter "${PYTHON}" --release --strip

# Install *.whl files using pip
$PYTHON -m pip install target/wheels/*.whl --no-deps --no-build-isolation --no-cache-dir -vvv
