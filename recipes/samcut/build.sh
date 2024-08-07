#!/bin/bash

set -ueo pipefail

export \
    CARGO_NET_GIT_FETCH_WITH_CLI=true \
    CARGO_HOME="${BUILD_PREFIX}/.cargo"

export BINDGEN_EXTRA_CLANG_ARGS="${CFLAGS} ${CPPFLAGS} ${LDFLAGS}"

RUST_BACKTRACE=1 cargo install --verbose --path . --root $PREFIX
