#!/bin/bash
set -euxo pipefail

mkdir -p $PREFIX/bin

# the binary expects libbz1.so.1, but the available one is libbz2.so.1.0
patchelf --replace-needed libbz2.so.1 libbz2.so.1.0 bin/magicblast

mv bin/magicblast $PREFIX/bin

