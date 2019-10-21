#!/bin/bash

set -ex

CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_LINKER=$CC

curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain nightly -y
export PATH="$HOME/.cargo/bin:$PATH"

$PYTHON -m pip install . --no-deps --ignore-installed -vv
