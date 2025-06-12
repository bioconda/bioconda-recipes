#!/bin/bash
scripts/install-zstd.sh
make CC=$CC zstd_local=../zstd/lib
mkdir -p $PREFIX/bin
cp slow5curl $PREFIX/bin/slow5curl
