#!/bin/bash
set -x

cd src/
make CC=$CC CPP=$CXX
mkdir -p $PREFIX/bin
cp SeSiMCMC $PREFIX/bin
