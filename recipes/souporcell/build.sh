#!/bin/bash -euo

mkdir -p ${PREFIX}/bin

export CFLAGS="${CFLAGS} -fcommon"
export CXXFLAGS="${CFLAGS} -fcommon -I${PREFIX}/include"

# Include scripts
cp -f stan_consensus.pickle $PREFIX/bin/stan_consensus.pickle
cp -f *py $PREFIX/bin
chmod +rx $PREFIX/bin/souporcell_pipeline.py

# Scripts expect the binary located in the following folder
mkdir -p $PREFIX/bin/souporcell/target/release
mkdir -p $PREFIX/bin/troublet/target/release

# Build statically linked binary with Rust
RUST_BACKTRACE=1
cargo install --verbose --root "${PREFIX}/bin/souporcell/target/release/" --path troublet
cargo install --verbose --root "${PREFIX}/bin/troublet/target/release/" --path souporcell
