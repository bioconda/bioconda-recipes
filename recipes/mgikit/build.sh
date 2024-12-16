#!/bin/bash -e

RUST_BACKTRACE=1
cargo install --no-track --verbose --root "${PREFIX}" --path .