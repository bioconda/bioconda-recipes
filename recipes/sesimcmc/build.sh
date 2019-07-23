#!/bin/bash
set -x

cd src/
make CC=$GCC CPP=$GXX
mkdir -p $PREFIX/
cp SeSiMCMC $PREFIX/bin
