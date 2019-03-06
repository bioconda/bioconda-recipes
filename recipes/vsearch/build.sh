#!/bin/bash
set -euo pipefail
sed -i.bak 's/10\.7/10.9/' configure.ac

./autogen.sh
./configure --prefix=$PREFIX
make
make install
