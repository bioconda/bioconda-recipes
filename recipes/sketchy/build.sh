#!/bin/bash
set -x
export RUST_BACKTRACE=full

# Fix for when some packages use ssh to fetch git repos
# See https://github.com/rust-lang/cargo/issues/1851#issuecomment-450130685
CARGO_NET_GIT_FETCH_WITH_CLI=true \
    cargo install -v --locked --root "${PREFIX}" --path .

"${PYTHON}" -m pip install --no-deps --ignore-installed -vv .
