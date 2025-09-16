#!/bin/bash
set -ex

# install an alpha release of pandora
VERSION="0.10.0-alpha.0.1"
URL="https://github.com/mbhall88/pandora/releases/download/${VERSION}/pandora-linux-precompiled-v$VERSION"

mkdir -p "$PREFIX/bin"

wget "$URL" -O "$PREFIX/bin/pandora"
chmod +x "$PREFIX/bin/pandora"

export CFLAGS="${CFLAGS} -fcommon"
export CXXFLAGS="${CFLAGS} -fcommon"
# Add workaround for SSH-based Git connections from Rust/cargo.  See https://github.com/rust-lang/cargo/issues/2078 for details.
# We set CARGO_HOME because we don't pass on HOME to conda-build, thus rendering the default "${HOME}/.cargo" defunct.
export CARGO_NET_GIT_FETCH_WITH_CLI=true CARGO_HOME="$(pwd)/.cargo"

export BINDGEN_EXTRA_CLANG_ARGS="${CFLAGS} ${CPPFLAGS} ${LDFLAGS}"

RUST_BACKTRACE=full

# build statically linked binary with Rust
export LD=$CC
C_INCLUDE_PATH=$PREFIX/include LIBRARY_PATH=$PREFIX/lib cargo install -v --root $PREFIX --path . --locked 