#!/bin/bash -euo
export CFLAGS="${CFLAGS} -fcommon"
export CXXFLAGS="${CFLAGS} -fcommon"

if [ "$(uname)" == "Darwin" ]; then
  if [[ $(uname -m) == 'x86_64' ]]; then
    echo "OSX x86-64: attempting to fix broken (old) SDK behavior"
    export CFLAGS="${CFLAGS} -D_LIBCPP_HAS_NO_C11_ALIGNED_ALLOC"
    export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_HAS_NO_C11_ALIGNED_ALLOC"
  fi
  export CFLAGS="${CFLAGS} -fno-define-target-os-macros"
  export CXXFLAGS="${CXXFLAGS} -fno-define-target-os-macros"
fi

# Add workaround for SSH-based Git connections from Rust/cargo.  See https://github.com/rust-lang/cargo/issues/2078 for details.
# We set CARGO_HOME because we don't pass on HOME to conda-build, thus rendering the default "${HOME}/.cargo" defunct.
export CARGO_NET_GIT_FETCH_WITH_CLI=true CARGO_HOME="$(pwd)/.cargo"

# build statically linked binary with Rust
RUST_BACKTRACE=1 cargo install --locked --verbose --root $PREFIX --path .
