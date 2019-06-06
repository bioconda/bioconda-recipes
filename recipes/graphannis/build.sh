#!/bin/bash

RUST_BACKTRACE=1 cargo build --release --features "cli c-api"

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/lib

cp ./target/release/annis ${PREFIX}/bin
cp ./target/release/libgraphannis.so ${PREFIX}/lib
