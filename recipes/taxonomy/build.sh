#!/bin/bash

set -ex

if [ `uname` == Darwin ]; then
  export HOME=`mktemp -d`
fi

curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain nightly --profile=minimal -y

export PATH="$HOME/.cargo/bin:$PATH"

export CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_LINKER="$CC"

maturin build --interpreter python --release --cargo-extra-args="--features=python"

$PYTHON -m pip install target/wheels/*.whl --no-deps --ignore-installed -vv
