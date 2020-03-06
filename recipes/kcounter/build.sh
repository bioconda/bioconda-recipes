#!/bin/bash

set -ex

rustup --default-toolchain nightly --profile=minimal -y

maturin build --interpreter python --release

$PYTHON -m pip install target/wheels/. --no-deps --ignore-installed -vv
