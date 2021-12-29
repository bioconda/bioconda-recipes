#!/bin/bash -euo

RUST_BACKTRACE=1 cargo install --locked --path . --root $PREFIX