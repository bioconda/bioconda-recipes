#!/bin/bash

set -eu -o pipefail

autoconf
./configure --prefix=${PREFIX}
make
make install
