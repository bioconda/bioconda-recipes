#!/bin/bash
set -eu -o pipefail

./configure --with-htslib=system
make
make install