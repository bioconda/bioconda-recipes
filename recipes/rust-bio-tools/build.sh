#!/bin/bash -e

# Dependency crate librocksdb-sys uses SSE4.1/4.2 and PCLMUL unconditionally.
# => Set architecture compatibility to "westmere".
export \
    CFLAGS="${CFLAGS} -march=westmere" \
    CXXFLAGS="${CXXFLAGS} -march=westmere"

export \
    CARGO_NET_GIT_FETCH_WITH_CLI=true \
    CARGO_HOME="${BUILD_PREFIX}/.cargo" \
    BINDGEN_EXTRA_CLANG_ARGS="${CFLAGS} ${CPPFLAGS} ${LDFLAGS}"

cargo install --path . --root "${PREFIX}" --verbose
