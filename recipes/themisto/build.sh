#!/bin/sh

export CFLAGS="$C -std=c++20"
export CXXFLAGS="$CXXFLAGS -std=c++20"

mkdir -p $PREFIX/bin

export RUSTUP_HOME="$HOME/rustup"
export CARGO_HOME="$HOME/cargo"
wget https://sh.rustup.rs -O rustup.sh
sh rustup.sh -y --default-toolchain nightly
export PATH="$CARGO_HOME/bin:$PATH"

git submodule update --init --recursive
cd build
cmake .. -DMAX_KMER_LENGTH=31 -DCMAKE_BUILD_ZLIB=1 -DCMAKE_BUILD_BZIP2=1
make -j${CPU_COUNT} ${VERBOSE_AT}

cp bin/themisto $PREFIX/bin
