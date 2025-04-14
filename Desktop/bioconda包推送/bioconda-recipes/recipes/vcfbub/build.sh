#!/bin/bash -euo

mkdir -p $PREFIX/bin

RUST_BACKTRACE=1 cargo install --verbose --path . --root ${PREFIX}
