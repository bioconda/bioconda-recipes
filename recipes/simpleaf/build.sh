#!/bin/bash -euo

export CFLAGS="${CFLAGS} -O3 -fcommon"
export CXXFLAGS="${CFLAGS} -fcommon"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

unamestr=`uname`

if [[ "$unamestr" == 'Darwin' ]];
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

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

if [[ "$unamestr" == 'Darwin' ]];
then
  # build statically linked binary with Rust
  CONDA_BUILD=TRUE RUSTFLAGS="-C link-args=-Wl,-undefined,dynamic_lookup" RUST_BACKTRACE=1 cargo install -v -v -j 1 --locked --verbose --root $PREFIX --path .
else 
  # build statically linked binary with Rust
  CONDA_BUILD=TRUE RUSTFLAGS="-L $PREFIX/lib64" RUST_BACKTRACE=1 cargo install -v -v --locked --verbose --root $PREFIX --path .
fi
