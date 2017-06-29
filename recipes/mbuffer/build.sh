#!/bin/bash
set -eu -o pipefail

./configure --prefix=$PREFIX
make
make install
