#!/bin/sh
set -eu -o pipefail

make
mkdir -p $PREFIX/bin
mv grabix $PREFIX/bin
