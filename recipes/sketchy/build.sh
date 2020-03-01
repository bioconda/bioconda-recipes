#!/bin/bash
set -x
export RUST_BACKTRACE=full

cargo install -v --locked --root "$PREFIX" --path .

"$PYTHON" -m pip install --no-deps --ignore-installed -vv .
