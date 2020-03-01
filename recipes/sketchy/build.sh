#!/bin/bash
set -x
export RUST_BACKTRACE=full

# See https://github.com/rust-lang/cargo/issues/2078
env CARGO_NET_GIT_FETCH_WITH_CLI=true \
    cargo install -v --locked --root "$PREFIX" --path .

"$PYTHON" -m pip install --no-deps --ignore-installed -vv .
