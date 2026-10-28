#!/bin/bash

set -xe

# build statically linked binary with Rust
RUST_BACKTRACE=1 cargo install --verbose --path ./chromsize/ --root ${PREFIX}
