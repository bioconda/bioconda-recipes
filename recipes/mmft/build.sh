#!/bin/bash
set -ex

RUST_BACKTRACE=full

if [ "$(uname)" == "Darwin" ]; then
    export HOME=`pwd`
    echo "HOME is $HOME"

    # according to https://github.com/rust-lang/cargo/issues/2422#issuecomment-198458960 removing circle ci default configuration solves cargo trouble downloading crates
    #git config --global --unset url.ssh://git@github.com.insteadOf
fi

cargo install -v --locked --root "$PREFIX" --path . --no-track
