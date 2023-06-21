#!/bin/bash

export INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

#export CFLAGS="${CFLAGS} -fcommon"
#export CXXFLAGS="${CXXFLAGS} -fcommon"

export CARGO_NET_GIT_FETCH_WITH_CLI=true CARGO_HOME="$(pwd)/.cargo"

# build statically linked binary with sage
RUST_BACKTRACE=1 cargo install --verbose -j 4 --root ${PREFIX} --path crates/sage-cli
