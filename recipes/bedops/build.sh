#!/bin/bash
set -eu -o pipefail

make
mkdir -p $PREFIX/bin
cp applications/bed/*/bin/* $PREFIX/bin
