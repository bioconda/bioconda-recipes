#!/bin/bash

set -xe

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

export CFLAGS="${CFLAGS} -O3 -fcommon -I${PREFIX}/include ${LDFLAGS}"
export CXXFLAGS="${CXXFLAGS} -O3 -fcommon -I${PREFIX}/include ${LDFLAGS}"

export CARGO_NET_GIT_FETCH_WITH_CLI=true CARGO_HOME="$(pwd)/.cargo"

# build statically linked binary with sage
RUST_BACKTRACE=1 cargo install --verbose -j ${CPU_COUNT} --root ${PREFIX} --path crates/sage-cli
