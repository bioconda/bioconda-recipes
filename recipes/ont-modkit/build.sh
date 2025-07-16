#!/bin/bash -euo

export CFLAGS="${CFLAGS} -fcommon"
export CXXFLAGS="${CFLAGS} -fcommon"

RUST_BACKTRACE=1 cargo install \
    --locked \
    --verbose \
    --root "${PREFIX}" \
    --path modkit

rm -rf "${PREFIX}/.crates"* "${PREFIX}/lib"
