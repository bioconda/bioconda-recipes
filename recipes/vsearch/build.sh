#!/bin/bash
set -euo pipefail
sed -i.bak '26iAC_CHECK_LIB(\[m\],\[cos\])' configure.ac

./autogen.sh
./configure --prefix=$PREFIX
make
make install
