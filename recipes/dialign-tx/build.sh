#!/bin/bash
set -euo pipefail

cd ./source

# disable CPPFLAGS in Makefile to
# - update architecture
# - disable SSE optimization
# - disable MMX optimization
#sed -i.bak -e 's/^CPPFLAGS=/#CPPFLAGS=/g' Makefile
# disable explicit CC setting
#sed -i.bak -e 's/^CC=/#CC=/g' Makefile

# set general CPPFLAGS (-funroll-loops taken from original Makefile)
#export CPPFLAGS="-I$PREFIX/include -O3 -march=native -funroll-loops"
#export LDFLAGS="-L$PREFIX/lib"

# fix source code: remove "inline" from structs
sed -i.bak -e 's/inline//g' *.c

mkdir -p $PREFIX/bin
make CC="$CC $CFLAGS $LDFLAGS" CPPFLAGS="$CPPFLAGS"
mv dialign-tx $PREFIX/bin/
