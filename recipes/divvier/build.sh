#!/bin/bash
set -eu -o pipefail

echo $PREFIX
CXX=$CXX
mkdir -p $PREFIX/bin
make
co divvier $PREFIX/bin
