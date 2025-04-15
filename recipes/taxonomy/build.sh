#!/bin/bash

set -euo

# Add workaround for SSH-based Git connections from Rust/cargo.  See https://github.com/rust-lang/cargo/issues/2078 for details.
# We set CARGO_HOME because we don't pass on HOME to conda-build, thus rendering the default "${HOME}/.cargo" defunct.
export CARGO_NET_GIT_FETCH_WITH_CLI=true CARGO_HOME="${BUILD_PREFIX}/.cargo"

if [ `uname` == Darwin ]; then
	export HOME=`mktemp -d`
	export PATH="$CARGO_HOME/bin:$PATH"
fi

# build statically linked binary with Rust
RUST_BACKTRACE=1
maturin build -b cffi --interpreter "${PYTHON}" --release --strip #--cargo-extra-args="--features=python"

${PYTHON} -m pip install . --no-deps --no-build-isolation -vvv
