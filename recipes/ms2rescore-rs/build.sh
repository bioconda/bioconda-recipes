#!/bin/bash

# -e = exit on first error
# -x = print every executed command
set -ex

# Add workaround for SSH-based Git connections from Rust/cargo.  See https://github.com/rust-lang/cargo/issues/2078 for details.
# We set CARGO_HOME because we don't pass on HOME to conda-build, thus rendering the default "${HOME}/.cargo" defunct.
export CARGO_NET_GIT_FETCH_WITH_CLI=true CARGO_HOME="${BUILD_PREFIX}/.cargo"

# Use a custom temporary directory as home on macOS.
# (not sure why this is useful, but people use it in bioconda recipes)
if [ `uname` == Darwin ]; then
  export HOME=`mktemp -d`
fi

# Build the package using maturin - should produce *.whl files.
maturin build --interpreter $PYTHON --release

# Install *.whl files using pip
$PYTHON -m pip install target/wheels/*.whl --no-deps --ignore-installed -vv
