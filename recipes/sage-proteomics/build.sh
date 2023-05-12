#!/bin/bash 

export CFLAGS="${CFLAGS} -fcommon"
export CXXFLAGS="${CFLAGS} -fcommon"

export CARGO_NET_GIT_FETCH_WITH_CLI=true CARGO_HOME="$(pwd)/.cargo"

# build statically linked binary with sage
RUST_BACKTRACE=1 cargo install --verbose --root $PREFIX --path crates/sage-cli
