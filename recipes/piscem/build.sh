#!/bin/bash -euo

unamestr=`uname`

if [ "$unamestr" == 'Darwin' ];
then
  export MACOSX_DEPLOYMENT_TARGET=10.15
  export CFLAGS="${CFLAGS} -fcommon -D_LIBCPP_DISABLE_AVAILABILITY"
  export CXXFLAGS="${CXXFLAGS} -fcommon -D_LIBCPP_DISABLE_AVAILABILITY"
else 
  export CFLAGS="${CFLAGS} -fcommon"
  export CXXFLAGS="${CXXFLAGS} -fcommon"
   # It's dumb and absurd that the KMC build can't find the bzip2 header <bzlib.h>
  export C_INCLUDE_PATH="${C_INCLUDE_PATH}:${PREFIX}/include"
  export CPLUS_INCLUDE_PATH="${CPLUS_INCLUDE_PATH}:${PREFIX}/include"
fi

# Add workaround for SSH-based Git connections from Rust/cargo.  See https://github.com/rust-lang/cargo/issues/2078 for details.
# We set CARGO_HOME because we don't pass on HOME to conda-build, thus rendering the default "${HOME}/.cargo" defunct.
export CARGO_NET_GIT_FETCH_WITH_CLI=true 
export CARGO_HOME="$(pwd)/.cargo"
export NUM_JOBS=1
export CARGO_BUILD_JOBS=1

if [ "$unamestr" == 'Darwin' ];
then

# build statically linked binary with Rust
RUSTFLAGS="-C link-args=-Wl,-undefined,dynamic_lookup" RUST_BACKTRACE=1 cargo install -v -v -j 1 --verbose --root $PREFIX --path .

else

export CFLAGS="${CFLAGS} --param ggc-min-expand=20 --param ggc-min-heapsize=8192"
export CXXFLAGS="${CXXFLAGS} --param ggc-min-expand=20 --param ggc-min-heapsize=8192"
# build statically linked binary with Rust
RUST_BACKTRACE=1 cargo install -v -v -j 1 --verbose --root $PREFIX --path .

fi
