#!/bin/bash
set -euo pipefail

cd ./source

# disable CPPFLAGS in Makefile to
# - update architecture
# - disable SSE optimization
# - disable MMX optimization
sed -i.bak 's/^CPPFLAGS=/#CPPFLAGS=/g' Makefile
# disable explicit CC setting
sed -i 's/^CC=/#CC=/g' Makefile

# set general CPPFLAGS (-funroll-loops taken from original Makefile)
export CPPFLAGS="-I$PREFIX/include -O3 -march=native -funroll-loops"
export LDFLAGS="-L$PREFIX/lib"

mkdir -p $PREFIX/bin
make
mv dialign-tx $PREFIX/bin/
