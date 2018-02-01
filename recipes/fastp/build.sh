#!/bin/bash
set -eu -o pipefail
make
mkdir -p $PREFIX/bin
cp fastp $PREFIX/bin
