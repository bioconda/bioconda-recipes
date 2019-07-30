#!/bin/bash

mkdir -p "$PREFIX/bin"
if [ "$(uname)" == "Darwin" ]; then
    cp bedGraphToBigWig "$PREFIX/bin"
else
    sed -i.bak "s|^CC=gcc$|CC='${CC}'|g" kent/src/inc/common.mk
    export MACHTYPE=x86_64
    export BINDIR=$(pwd)/bin
    mkdir -p "$BINDIR"
    (cd kent/src/lib && make)
    (cd kent/src/htslib && make)
    (cd kent/src/jkOwnLib && make)
    (cd kent/src/hg/lib && make)
    (cd kent/src/utils/bedGraphToBigWig && make)
    cp bin/bedGraphToBigWig "$PREFIX/bin"
fi
chmod +x "$PREFIX/bin/bedGraphToBigWig"
