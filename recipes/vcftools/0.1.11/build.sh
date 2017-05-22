#!/bin/bash
set -euo pipefail
export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
sed -i.bak -e 's/DIRS = cpp perl/DIRS = cpp/' ./Makefile
make
make install
