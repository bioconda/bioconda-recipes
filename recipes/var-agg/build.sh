#!/bin/bash -e

# Add workaround for SSH-based Git connections from Rust/cargo.  See https://github.com/rust-lang/cargo/issues/2078 for details.
# We set CARGO_HOME because we don't pass on HOME to conda-build, thus rendering the default "${HOME}/.cargo" defunct.
export CARGO_NET_GIT_FETCH_WITH_CLI=true CARGO_HOME="$(pwd)/.cargo"
# Make sure bindgen passes on our compiler flags.
# export BINDGEN_EXTRA_CLANG_ARGS="${CPPFLAGS} ${CFLAGS} ${LDFLAGS}"
# Can't use BINDGEN_EXTRA_CLANG_ARGS because we depend on rust-htslib<0.23 which uses bindgen<0.49.
export C_INCLUDE_PATH=$PREFIX/include

cargo install --path . --root $PREFIX
