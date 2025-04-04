#!/bin/bash -euo

export CARGO_HOME="$(pwd)/.cargo"
RUST_BACKTRACE=1 cargo install --locked --path . --root $PREFIX