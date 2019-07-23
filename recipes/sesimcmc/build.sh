#!/bin/bash
set -x

cd src/
make CC=$GCC CPP=$GXX
mkdir -p $PREFIX/bin
cp SeSiMCMC $PREFIX/bin
