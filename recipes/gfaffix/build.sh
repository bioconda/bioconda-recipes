#!/bin/bash -euo


mkdir -p $PREFIX/bin

RUST_BACKTRACE=1 cargo install --no-track --verbose --root "${PREFIX}" --path .

