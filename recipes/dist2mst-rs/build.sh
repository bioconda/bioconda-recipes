#!/bin/bash
set -ex
RUSTFLAGS="-C target-cpu=x86-64-v2" cargo install --no-track --locked --root "$PREFIX" --path .
