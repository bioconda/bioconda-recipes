#!/bin/bash
set -x
export RUST_BACKTRACE=full

# Add workaround for SSH-based Git connections from Rust/cargo.  See https://github.com/rust-lang/cargo/issues/2078 for details.
# We set CARGO_HOME because we don't pass on HOME to conda-build, thus rendering the default "${HOME}/.cargo" defunct.
export CARGO_NET_GIT_FETCH_WITH_CLI=true CARGO_HOME="$(pwd)/.cargo"

cargo install -v --locked --root "${PREFIX}" --path .

"${PYTHON}" -m pip install --no-deps --ignore-installed -vv .
