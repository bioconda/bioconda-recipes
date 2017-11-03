#!/bin/bash
set -euo pipefail
export CPPFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
./autogen.sh
./configure --prefix=$PREFIX
make
make install
