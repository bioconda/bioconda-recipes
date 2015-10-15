#!/bin/bash

cargo build --release

mkdir -p $PREFIX/bin
cp target/release/xsv $PREFIX/bin
