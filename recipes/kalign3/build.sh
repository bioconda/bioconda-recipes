#!/bin/bash
set -eo pipefail

# create configure file
./autogen.sh

# run configuration
./configure --prefix="${PREFIX}"

# compile and install
make CFLAGS="${CFLAGS} -fcommon"
make install
