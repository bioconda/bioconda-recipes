#!/bin/bash

set -ex

if [ `uname` == Darwin ]; then
  export HOME=`mktemp -d`
fi

curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain nightly-2019-09-26 --profile=minimal -y
export PATH="$HOME/.cargo/bin:$PATH"

export CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_LINKER="$CC"

$PYTHON -m pip install . --no-deps --ignore-installed -vv
