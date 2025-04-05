#!/bin/bash -euo

set -xe

RUST_BACKTRACE=full
cargo install -v --locked --root "$PREFIX" --path .