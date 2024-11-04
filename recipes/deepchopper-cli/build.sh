#!/bin/bash

# -e = exit on first error
# -x = print every executed command
set -ex

# if [ `uname` == Darwin ]; then
#   export HOME=`mktemp -d`
# fi

curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain nightly --profile=minimal -y

export PATH="$HOME/.cargo/bin:$PATH"

cd py_cli

maturin build --interpreter python --release -b bin --out dist

$PYTHON -m pip install dist/*.whl --no-deps --ignore-installed -vv
