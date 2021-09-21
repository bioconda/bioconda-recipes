#!/bin/bash

# Source archive contains some macOS junk files,
# which prevent hoisting the HMMcopy on Linux only.
cd HMMcopy || true
cmake .
make
mkdir -p $PREFIX/bin
cp bin/* $PREFIX/bin
