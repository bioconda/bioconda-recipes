#!/bin/bash
set -euo pipefail

CFLAGS="-lm" 

./autogen.sh
./configure --prefix=$PREFIX
make
make install
