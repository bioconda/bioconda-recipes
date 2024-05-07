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

# Build statically linked binary with Rust
# Note: This sdist is a bit wonky because it was generated from a monorepo by running maturin sdist
RUST_BACKTRACE=1 

# Creating the sdist from the monorepo placed pyproject.toml one level above Cargo.toml.
# The wheels don't seem to install as expected unless pyproject.toml is moved back into the source dir.
mv pyproject.toml pybigtools/

# Run maturin build to produce *.whl files.
maturin build -m pybigtools/Cargo.toml -b pyo3 --interpreter "${PYTHON}" --release --strip

# Install *.whl files using pip
${PYTHON} -m pip install pybigtools/target/wheels/*.whl --no-deps --no-build-isolation --no-cache-dir -vvv

# Move the LICENSE file to the root dir
mv pybigtools/LICENSE .