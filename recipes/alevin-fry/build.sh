#!/bin/bash -euo
export CFLAGS="${CFLAGS} -fcommon"
export CXXFLAGS="${CFLAGS} -fcommon"

# Add workaround for SSH-based Git connections from Rust/cargo.  See https://github.com/rust-lang/cargo/issues/2078 for details.
# We set CARGO_HOME because we don't pass on HOME to conda-build, thus rendering the default "${HOME}/.cargo" defunct.
export CARGO_NET_GIT_FETCH_WITH_CLI=true CARGO_HOME="$(pwd)/.cargo"

# get the version of libradicl on which we will be depending
LIBRAD_VER=`grep 'libradicl' Cargo.toml | grep -oh 'version = "[^\"]\+"' | grep -oh '"[^\"]\+"'`

# build statically linked binary with Rust
RUST_BACKTRACE=1 cargo install --config 'patch."https://github.com/COMBINE-lab/libradicl".libradicl='$LIBRAD_VER'' --verbose --root $PREFIX --path .
