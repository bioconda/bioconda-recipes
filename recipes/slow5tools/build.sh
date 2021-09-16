#!/bin/bash
scripts/install-zstd.sh
./configure  --enable-localzstd
make
mkdir -p $PREFIX/bin
cp slow5tools $PREFIX/bin/slow5tools
