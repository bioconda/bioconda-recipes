#!/bin/bash
set -euo pipefail
./autogen.sh
./configure --prefix=$PREFIX
make
make install
