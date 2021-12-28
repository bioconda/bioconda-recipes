#!/bin/bash -euo

RUST_BACKTRACE=1 cargo install --verbose --path . --root $PREFIX