#!/bin/bash
set -eu -o pipefail

cmake -DHTSLIB_DIR=htslib
make

mkdir -p ${PREFIX}/bin
cp bin/svaba ${PREFIX}/bin/
