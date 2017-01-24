#!/bin/bash
set -euo pipefail
cp makefile.new src

if [ `uname` == Darwin ]; then
    export CXXFLAGS="${CXXFLAGS} -std=c++0x -stdlib=libc++"
fi
cd src && make -f makefile.new
cp MaxBin $PREFIX/bin/
