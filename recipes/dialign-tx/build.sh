#!/bin/bash
set -euo pipefail

cd ./source

# disable CPPFLAGS in Makefile to
# - update architecture
# - disable SSE optimization
# - disable MMX optimization
sed -i.bak -e 's/^(CPPFLAGS=.*)$/#\1/g' Makefile
# disable explicit CC setting
sed -i -e 's/^(CC=.*)$/#\1/g' Makefile

# set general CPPFLAGS (-funroll-loops taken from original Makefile)
export CPPFLAGS="-I$PREFIX/include -O3 -march=native -funroll-loops"
export LDFLAGS="-L$PREFIX/lib"

mkdir -p $PREFIX/bin
make
mv dialign-tx $PREFIX/bin/
