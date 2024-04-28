#!/bin/bash
set -ex
export LIBRARY_PATH=${PREFIX}/lib
export LD_LIBRARY_PATH=${PREFIX}/lib
export CPATH=${PREFIX}/include
export C_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export CPP_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include

RUST_BACKTRACE=1 CARGO_HOME="${BUILD_PREFIX}/.cargo" cargo build --release

mkdir -p $PREFIX/bin
cp target/release/wgatools $PREFIX/bin 
