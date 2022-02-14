#!/bin/sh
set -eux -o pipefail

 ./configure --prefix=${PREFIX}
make
make install
