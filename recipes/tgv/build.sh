#!/bin/bash
set -e -x

export LIBCLANG_PATH="${PREFIX}/lib"
cargo install --path . --root "$PREFIX"
