#!/bin/bash
set -euo pipefail
export CPPFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
./autogen.sh
./configure --prefix=$PREFIX
sed -i.bak -e 's/SUBDIRS = cpp perl/SUBDIRS = cpp/' ./src/Makefile
make
make install
