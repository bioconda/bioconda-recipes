#!/bin/bash
set -x
export RUST_BACKTRACE=full

if [ "$(uname)" == "Darwin" ]; then
    # according to https://github.com/rust-lang/cargo/issues/2422#issuecomment-198458960 removing circle ci default configuration solves cargo trouble downloading crates
    git config --global --unset url.ssh://git@github.com:.insteadof
fi

cargo install -v --locked --root "$PREFIX" --path .

"$PYTHON" -m pip install --no-deps --ignore-installed -vv .
