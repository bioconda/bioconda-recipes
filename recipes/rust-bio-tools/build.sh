#!/bin/bash -e

# Dependency crate librocksdb-sys uses SSE4.1/4.2 unconditionally.
# => Set architecture compatibility to "nehalem".
export \
    CFLAGS="${CFLAGS} -march=nehalem" \
    CXXFLAGS="${CXXFLAGS} -march=nehalem"

export \
    CARGO_NET_GIT_FETCH_WITH_CLI=true \
    CARGO_HOME="${BUILD_PREFIX}/.cargo" \
    BINDGEN_EXTRA_CLANG_ARGS="${CFLAGS} ${CPPFLAGS} ${LDFLAGS}"

cargo install --path . --root "${PREFIX}" --verbose
