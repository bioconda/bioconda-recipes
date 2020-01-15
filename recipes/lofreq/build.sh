#!/bin/bash
set -eu -o pipefail

./configure --with-htslib=${PREFIX}/include
make
make install