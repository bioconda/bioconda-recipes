#!/bin/bash -euo
export CFLAGS="${CFLAGS} -fcommon"
export CXXFLAGS="${CFLAGS} -fcommon"

unamestr=`uname`

if [ "$unamestr" == 'Darwin' ];
then
  if [[ $(uname -m) == 'x86_64' ]]; then
    echo "OSX x86-64: attempting to fix broken (old) SDK behavior"
    export CFLAGS="${CFLAGS} -D_LIBCPP_HAS_NO_C11_ALIGNED_ALLOC -UHAVE_ALIGNED_ALLOC -D__APPLE__"
    export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_HAS_NO_C11_ALIGNED_ALLOC -UHAVE_ALIGNED_ALLOC -D__APPLE__"
  fi
  export MACOSX_DEPLOYMENT_TARGET=10.15
  export MACOSX_SDK_VERSION=10.15
  export CFLAGS="${CFLAGS} -fcommon -D_LIBCPP_DISABLE_AVAILABILITY -fno-define-target-os-macros"
  export CXXFLAGS="${CXXFLAGS} -fcommon -D_LIBCPP_DISABLE_AVAILABILITY"
fi

# Add workaround for SSH-based Git connections from Rust/cargo.  See https://github.com/rust-lang/cargo/issues/2078 for details.
# We set CARGO_HOME because we don't pass on HOME to conda-build, thus rendering the default "${HOME}/.cargo" defunct.
export CARGO_NET_GIT_FETCH_WITH_CLI=true 
export CARGO_HOME="$(pwd)/.cargo"

# build statically linked binary with Rust
RUST_BACKTRACE=1 cargo install --verbose --root $PREFIX --path .
