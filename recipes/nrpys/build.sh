#!/bin/bash -euo

# Add workaround for SSH-based Git connections from Rust/cargo.  See https://github.com/rust-lang/cargo/issues/2078 for details.
# We set CARGO_HOME because we don't pass on HOME to conda-build, thus rendering the default "${HOME}/.cargo" defunct.
export CARGO_NET_GIT_FETCH_WITH_CLI=true CARGO_HOME="$(pwd)/.cargo"

export HOME=${PREFIX}

export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

mkdir -p ${PREFIX}/bin

# build statically linked binary with Rust
maturin build --release -f
pip install -vv -e .
cp ${SRC_DIR}/python/nrpys/nrpys.*.so ${PREFIX}/lib/libnrpys.so
