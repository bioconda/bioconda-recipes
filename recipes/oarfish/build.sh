#!/bin/bash -euo

set -xe

unamestr=`uname`
if [ "$unamestr" == 'Darwin' ];
then
  export CC=clang
  export CXX=clang++
else
  export CC=gcc
  export CXX=g++
fi

curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain stable --profile=minimal -y
export PATH="$HOME/.cargo/bin:$PATH"


# build statically linked binary with Rust
RUST_BACKTRACE=1 cargo install --verbose --root $PREFIX --path .
