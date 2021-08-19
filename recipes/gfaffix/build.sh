#!/bin/bash -euo

RUST_BACKTRACE=1 CARGO_HOME="${BUILD_PREFIX}/.cargo" cargo install --path . --root "${PREFIX}" --verbose --no-track 
