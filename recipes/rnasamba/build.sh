#!/bin/bash

set -ex

curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain nightly -y
export PATH="$HOME/.cargo/bin:$PATH"

$PYTHON -m pip install . --no-deps --ignore-installed -vv
