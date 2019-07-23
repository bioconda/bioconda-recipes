#!/bin/bash
set -x

cd src/
make CC=$GCC CPP=$GXX
mkdir -p $PREFIX_DIR/
cp SeSiMCMC $PREFIX_DIR/bin
